"""Prepare transparent Piplup and a purple Joey variant from the original GIF."""
import colorsys
from collections import deque
from pathlib import Path
from theme_gif import transparent_frames, save_animation

source = Path(__file__).resolve().parent.parent / "assets/piplup/piplup-sprite.gif"
target = source.parent.parent / "Resources/PiplupTheme.gif"

def remove_pale_matte(frame):
    """Remove the exterior pale matte, stopping at white character details."""
    result = frame.copy()
    pixels = result.load()
    width, height = result.size
    queue = deque((x, y) for y in range(height) for x in range(width)
                  if pixels[x, y][3] == 0)
    visited = set()
    removed = 0
    while queue:
        x, y = queue.popleft()
        if (x, y) in visited or not (0 <= x < width and 0 <= y < height):
            continue
        visited.add((x, y))
        red, green, blue, alpha = pixels[x, y]
        is_matte = min(red, green, blue) >= 185 and 0 < max(red, green, blue) - min(red, green, blue) <= 40
        if alpha and not is_matte:
            continue
        removed += bool(alpha)
        pixels[x, y] = (red, green, blue, 0)
        queue.extend((x+dx, y+dy) for dx in (-1, 0, 1) for dy in (-1, 0, 1) if dx or dy)
    for before, after in zip(frame.get_flattened_data(), result.get_flattened_data()):
        assert before[:3] == after[:3], "Cleanup must not recolor the sprite"
        if before == (255, 255, 255, 255):
            assert after == before, "White face and belly details must remain opaque"
    print(f"PASS: removed {removed} exterior matte pixels; white sprite details unchanged")
    return result


def purple_variant(frame):
    result = frame.copy()
    colors = []
    for red, green, blue, alpha in frame.get_flattened_data():
        hue, saturation, value = colorsys.rgb_to_hsv(red / 255, green / 255, blue / 255)
        if alpha and 180 <= hue * 360 <= 240 and saturation > 0.08:
            red, green, blue = (round(channel * 255) for channel in
                                colorsys.hsv_to_rgb((hue + 75 / 360) % 1, saturation, value))
        colors.append((red, green, blue, alpha))
    result.putdata(colors)
    return result



frames, durations, loop = transparent_frames(source)
frames = [remove_pale_matte(frame) for frame in frames]
save_animation(target, frames, durations, loop)
save_animation(target.with_name("JoeyTheme.gif"), [purple_variant(frame) for frame in frames], durations, loop)
