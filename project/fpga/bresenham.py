def bresenham_line(x1, y1, x2, y2):
    # Calculate the differences
    dx = abs(x2 - x1)
    dy = abs(y2 - y1)

    # Identify the direction of the line
    x_increment = 1 if x1 < x2 else -1
    y_increment = 1 if y1 < y2 else -1

    # Initialize the current point
    x, y = x1, y1

    # Initialize the list of points to be plotted
    points = [(x, y)]

    # Check if the line is steep or shallow
    if dx >= dy:
        # Shallow line
        d = (2 * dy) - dx

        for _ in range(dx):
            x += x_increment

            if d >= 0:
                y += y_increment
                d -= 2 * dx

            d += 2 * dy
            points.append((x, y))
    else:
        # Steep line
        d = (2 * dx) - dy

        for _ in range(dy):
            y += y_increment

            if d >= 0:
                x += x_increment
                d -= 2 * dy

            d += 2 * dx
            points.append((x, y))

    return points

# Example usage
x1, y1 = 0, 0
x2, y2 = 100, 100
points = bresenham_line(x1, y1, x2, y2)

for point in points:
    print(point)