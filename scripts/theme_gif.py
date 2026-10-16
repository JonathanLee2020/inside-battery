"""Prepare transparent animated sprites with verified timing and bounded palette error."""
from collections import Counter, deque
from pathlib import Path
from PIL import Image, ImageSequence


def transparent_frames(source, white_threshold=250):
    original = Image.open(source)
    frames, durations = [], []
    bounds = None
    for frame in ImageSequence.Iterator(original):
        rgba = frame.convert("RGBA")
        pixels = rgba.load()
        width, height = rgba.size
        queue = deque([(x, y) for x in range(width) for y in (0, height - 1)]
                      + [(x, y) for y in range(height) for x in (0, width - 1)])
        visited = set()
        while queue:
            x, y = queue.popleft()
            if (x, y) in visited or not (0 <= x < width and 0 <= y < height):
                continue
            visited.add((x, y))
            red, green, blue, alpha = pixels[x, y]
            if alpha and min(red, green, blue) < white_threshold:
                continue
            pixels[x, y] = (red, green, blue, 0)
            queue.extend(((x-1, y), (x+1, y), (x, y-1), (x, y+1)))
        box = rgba.getbbox()
        assert box, "Source frame must contain a sprite"
        bounds = box if bounds is None else (
            min(bounds[0], box[0]), min(bounds[1], box[1]),
            max(bounds[2], box[2]), max(bounds[3], box[3]))
        frames.append(rgba)
        durations.append(frame.info.get("duration", 100))
    return [frame.crop(bounds) for frame in frames], durations, original.info.get("loop", 0)


def save_animation(path, prepared, durations, loop):
    output = []
    max_color_delta = 0
    for frame in prepared:
        pixels = list(frame.get_flattened_data())
        counts = Counter(pixel[:3] for pixel in pixels if pixel[3])
        colors = sorted(counts)
        replacements = {}
        while len(colors) > 255:
            distance, first, second = min(
                (sum((a-b)**2 for a, b in zip(first, second)), first, second)
                for index, first in enumerate(colors) for second in colors[index+1:])
            removed, retained = (first, second) if counts[first] <= counts[second] else (second, first)
            delta = max(abs(a-b) for a, b in zip(removed, retained))
            assert delta <= 8, "Palette reduction would visibly alter the sprite"
            max_color_delta = max(max_color_delta, delta)
            replacements[removed] = retained
            counts[retained] += counts[removed]
            colors.remove(removed)
        indices = {color: index for index, color in enumerate(colors)}
        for removed, retained in replacements.items():
            while retained in replacements:
                retained = replacements[retained]
            indices[removed] = indices[retained]
        palette = Image.new("P", frame.size)
        rgb_palette = [channel for color in colors for channel in color]
        palette.putpalette(rgb_palette + [0] * (768 - len(rgb_palette)))
        palette.putdata([indices[pixel[:3]] if pixel[3] else 255 for pixel in pixels])
        palette.info["transparency"] = 255
        output.append(palette)
    output[0].save(path, save_all=True, append_images=output[1:], duration=durations,
                   loop=loop, transparency=255, disposal=2, optimize=False)
    result = Image.open(path)
    assert result.n_frames == len(prepared)
    assert result.info.get("loop") == loop
    for index, frame in enumerate(ImageSequence.Iterator(result)):
        actual = frame.convert("RGBA")
        assert frame.info["duration"] == durations[index]
        for a, b in zip(prepared[index].get_flattened_data(), actual.get_flattened_data()):
            assert a[3] == b[3], "Transparency must match the prepared frame"
            assert not a[3] or max(abs(x-y) for x,y in zip(a[:3],b[:3])) <= max_color_delta, "Palette error exceeds measured limit"
    print(f"PASS: {result.n_frames} transparent frames, {result.size}, timing preserved, maximum palette delta {max_color_delta}/255: {path}")



if __name__ == "__main__":
    import sys
    frames, durations, loop = transparent_frames(Path(sys.argv[1]), int(sys.argv[3]) if len(sys.argv) > 3 else 250)
    save_animation(Path(sys.argv[2]), frames, durations, loop)
