from PIL import Image, ImageDraw
import sys

if len(sys.argv) <= 1:
    print("Please provide an export path")
    sys.exit(1)
outPath = sys.argv[1]

# size of image
canvas = (1920, 1080)

# init canvas
im = Image.new('RGB', canvas, (255, 255, 255))
draw = ImageDraw.Draw(im)

'''
colours = [
    (0,0,0),
    (26,23,40),
    (57,27,47,),
    (89,40,35),
    (133,64,40),
    (233,83,0),
    (219,139,73),
    (243,180,130),
    (252,243,0),
    (133,232,30),
    (60,184,0),
    (0,135,88),
    (52,89,28),
    (66,59,22),
    (36,46,43),
    (48,46,100),
    (22,78,114),
    (68,85,227),
    (64,135,255),
    (28,199,225),
    (188,210,255),
    (255,255,255),
    (133,158,170),
    (114,106,117),
    (86,87,87),
    (71,68,64),
    (205,200,85),
    (171,15,33),
    (227,50,77),
    (221,90,175),
    (123,136,46),
    (124,91,25)
]
'''

'''
colours = [
    (255, 255, 255),
    (255, 255, 204),
    (255, 255, 153),
    (255, 255, 102),
    (255, 255, 51),
    (255, 255, 0),
    (255, 204, 255),
    (255, 204, 204),
    (255, 204, 153),
    (255, 204, 102),
    (255, 204, 51),
    (255, 204, 0),
    (255, 153, 255),
    (255, 153, 204),
    (255, 153, 153),
    (255, 153, 102),
    (255, 153, 51),
    (255, 153, 0),
    (255, 102, 255),
    (255, 102, 204),
    (255, 102, 153),
    (255, 102, 102),
    (255, 102, 51),
    (255, 102, 0),
    (255, 51,  255),
    (255, 51,  204),
    (255, 51,  153),
    (255, 51,  102),
    (255, 51,  51),
    (255, 51,  0),
    (255, 0,   255),
    (255, 0,   204),
    (255, 0,   153),
    (255, 0,   102),
    (255, 0,   51),
    (255, 0,   0),
    (204, 255, 255),
    (204, 255, 204),
    (204, 255, 153),
    (204, 255, 102),
    (204, 255, 51),
    (204, 255, 0),
    (204, 204, 255),
    (204, 204, 204),
    (204, 204, 153),
    (204, 204, 102),
    (204, 204, 51),
    (204, 204, 0),
    (204, 153, 255),
    (204, 153, 204),
    (204, 153, 153),
    (204, 153, 102),
    (204, 153, 51),
    (204, 153, 0),
    (204, 102, 255),
    (204, 102, 204),
    (204, 102, 153),
    (204, 102, 102),
    (204, 102, 51),
    (204, 102, 0),
    (204, 51,  255),
    (204, 51,  204),
    (204, 51,  153),
    (204, 51,  102),
    (204, 51,  51),
    (204, 51,  0),
    (204, 0,   255),
    (204, 0,   204),
    (204, 0,   153),
    (204, 0,   102),
    (204, 0,   51),
    (204, 0,   0),
    (153, 255, 255),
    (153, 255, 204),
    (153, 255, 153),
    (153, 255, 102),
    (153, 255, 51),
    (153, 255, 0),
    (153, 204, 255),
    (153, 204, 204),
    (153, 204, 153),
    (153, 204, 102),
    (153, 204, 51),
    (153, 204, 0),
    (153, 153, 255),
    (153, 153, 204),
    (153, 153, 153),
    (153, 153, 102),
    (153, 153, 51),
    (153, 153, 0),
    (153, 102, 255),
    (153, 102, 204),
    (153, 102, 153),
    (153, 102, 102),
    (153, 102, 51),
    (153, 102, 0),
    (153, 51,  255),
    (153, 51,  204),
    (153, 51,  153),
    (153, 51,  102),
    (153, 51,  51),
    (153, 51,  0),
    (153, 0,   255),
    (153, 0,   204),
    (153, 0,   153),
    (153, 0,   102),
    (153, 0,   51),
    (153, 0,   0),
    (102, 255, 255),
    (102, 255, 204),
    (102, 255, 153),
    (102, 255, 102),
    (102, 255, 51),
    (102, 255, 0),
    (102, 204, 255),
    (102, 204, 204),
    (102, 204, 153),
    (102, 204, 102),
    (102, 204, 51),
    (102, 204, 0),
    (102, 153, 255),
    (102, 153, 204),
    (102, 153, 153),
    (102, 153, 102),
    (102, 153, 51),
    (102, 153, 0),
    (102, 102, 255),
    (102, 102, 204),
    (102, 102, 153),
    (102, 102, 102),
    (102, 102, 51),
    (102, 102, 0),
    (102, 51,  255),
    (102, 51,  204),
    (102, 51,  153),
    (102, 51,  102),
    (102, 51,  51),
    (102, 51,  0),
    (102, 0,   255),
    (102, 0,   204),
    (102, 0,   153),
    (102, 0,   102),
    (102, 0,   51),
    (102, 0,   0),
    (51,  255, 255),
    (51,  255, 204),
    (51,  255, 153),
    (51,  255, 102),
    (51,  255, 51),
    (51,  255, 0),
    (51,  204, 255),
    (51,  204, 204),
    (51,  204, 153),
    (51,  204, 102),
    (51,  204, 51),
    (51,  204, 0),
    (51,  153, 255),
    (51,  153, 204),
    (51,  153, 153),
    (51,  153, 102),
    (51,  153, 51),
    (51,  153, 0),
    (51,  102, 255),
    (51,  102, 204),
    (51,  102, 153),
    (51,  102, 102),
    (51,  102, 51),
    (51,  102, 0),
    (51,  51,  255),
    (51,  51,  204),
    (51,  51,  153),
    (51,  51,  102),
    (51,  51,  51),
    (51,  51,  0),
    (51,  0,   255),
    (51,  0,   204),
    (51,  0,   153),
    (51,  0,   102),
    (51,  0,   51),
    (51,  0,   0),
    (0,   255, 255),
    (0,   255, 204),
    (0,   255, 153),
    (0,   255, 102),
    (0,   255, 51),
    (0,   255, 0),
    (0,   204, 255),
    (0,   204, 204),
    (0,   204, 153),
    (0,   204, 102),
    (0,   204, 51),
    (0,   204, 0),
    (0,   153, 255),
    (0,   153, 204),
    (0,   153, 153),
    (0,   153, 102),
    (0,   153, 51),
    (0,   153, 0),
    (0,   102, 255),
    (0,   102, 204),
    (0,   102, 153),
    (0,   102, 102),
    (0,   102, 51),
    (0,   102, 0),
    (0,   51,  255),
    (0,   51,  204),
    (0,   51,  153),
    (0,   51,  102),
    (0,   51,  51),
    (0,   51,  0),
    (0,   0,   255),
    (0,   0,   204),
    (0,   0,   153),
    (0,   0,   102),
    (0,   0,   51),
    (238, 0,   0),
    (221, 0,   0),
    (187, 0,   0),
    (170, 0,   0),
    (136, 0,   0),
    (119, 0,   0),
    (85,  0,   0),
    (68,  0,   0),
    (34,  0,   0),
    (17,  0,   0),
    (0,   238, 0),
    (0,   221, 0),
    (0,   187, 0),
    (0,   170, 0),
    (0,   136, 0),
    (0,   119, 0),
    (0,   85,  0),
    (0,   68,  0),
    (0,   34,  0),
    (0,   17,  0),
    (0,   0,   238),
    (0,   0,   221),
    (0,   0,   187),
    (0,   0,   170),
    (0,   0,   136),
    (0,   0,   119),
    (0,   0,   85),
    (0,   0,   68),
    (0,   0,   34),
    (0,   0,   17),
    (238, 238, 238),
    (221, 221, 221),
    (187, 187, 187),
    (170, 170, 170),
    (136, 136, 136),
    (119, 119, 119),
    (85,  85,  85),
    (68,  68,  68),
    (34,  34,  34),
    (17,  17,  17),
    (0,   0,   0)
]
'''

colours = [
    "#FFFFFF",
    "#FFFFCC",
    "#FFFF99",
    "#FFFF66",
    "#FFFF33",
    "#FFFF00",
    "#FFCCFF",
    "#FFCCCC",
    "#FFCC99",
    "#FFCC66",
    "#FFCC33",
    "#FFCC00",
    "#FF99FF",
    "#FF99CC",
    "#FF9999",
    "#FF9966",
    "#FF9933",
    "#FF9900",
    "#FF66FF",
    "#FF66CC",
    "#FF6699",
    "#FF6666",
    "#FF6633",
    "#FF6600",
    "#FF33FF",
    "#FF33CC",
    "#FF3399",
    "#FF3366",
    "#FF3333",
    "#FF3300",
    "#FF00FF",
    "#FF00CC",
    "#FF0099",
    "#FF0066",
    "#FF0033",
    "#FF0000",
    "#CCFFFF",
    "#CCFFCC",
    "#CCFF99",
    "#CCFF66",
    "#CCFF33",
    "#CCFF00",
    "#CCCCFF",
    "#CCCCCC",
    "#CCCC99",
    "#CCCC66",
    "#CCCC33",
    "#CCCC00",
    "#CC99FF",
    "#CC99CC",
    "#CC9999",
    "#CC9966",
    "#CC9933",
    "#CC9900",
    "#CC66FF",
    "#CC66CC",
    "#CC6699",
    "#CC6666",
    "#CC6633",
    "#CC6600",
    "#CC33FF",
    "#CC33CC",
    "#CC3399",
    "#CC3366",
    "#CC3333",
    "#CC3300",
    "#CC00FF",
    "#CC00CC",
    "#CC0099",
    "#CC0066",
    "#CC0033",
    "#CC0000",
    "#99FFFF",
    "#99FFCC",
    "#99FF99",
    "#99FF66",
    "#99FF33",
    "#99FF00",
    "#99CCFF",
    "#99CCCC",
    "#99CC99",
    "#99CC66",
    "#99CC33",
    "#99CC00",
    "#9999FF",
    "#9999CC",
    "#999999",
    "#999966",
    "#999933",
    "#999900",
    "#9966FF",
    "#9966CC",
    "#996699",
    "#996666",
    "#996633",
    "#996600",
    "#9933FF",
    "#9933CC",
    "#993399",
    "#993366",
    "#993333",
    "#993300",
    "#9900FF",
    "#9900CC",
    "#990099",
    "#990066",
    "#990033",
    "#990000",
    "#66FFFF",
    "#66FFCC",
    "#66FF99",
    "#66FF66",
    "#66FF33",
    "#66FF00",
    "#66CCFF",
    "#66CCCC",
    "#66CC99",
    "#66CC66",
    "#66CC33",
    "#66CC00",
    "#6699FF",
    "#6699CC",
    "#669999",
    "#669966",
    "#669933",
    "#669900",
    "#6666FF",
    "#6666CC",
    "#666699",
    "#666666",
    "#666633",
    "#666600",
    "#6633FF",
    "#6633CC",
    "#663399",
    "#663366",
    "#663333",
    "#663300",
    "#6600FF",
    "#6600CC",
    "#660099",
    "#660066",
    "#660033",
    "#660000",
    "#33FFFF",
    "#33FFCC",
    "#33FF99",
    "#33FF66",
    "#33FF33",
    "#33FF00",
    "#33CCFF",
    "#33CCCC",
    "#33CC99",
    "#33CC66",
    "#33CC33",
    "#33CC00",
    "#3399FF",
    "#3399CC",
    "#339999",
    "#339966",
    "#339933",
    "#339900",
    "#3366FF",
    "#3366CC",
    "#336699",
    "#336666",
    "#336633",
    "#336600",
    "#3333FF",
    "#3333CC",
    "#333399",
    "#333366",
    "#333333",
    "#333300",
    "#3300FF",
    "#3300CC",
    "#330099",
    "#330066",
    "#330033",
    "#330000",
    "#00FFFF",
    "#00FFCC",
    "#00FF99",
    "#00FF66",
    "#00FF33",
    "#00FF00",
    "#00CCFF",
    "#00CCCC",
    "#00CC99",
    "#00CC66",
    "#00CC33",
    "#00CC00",
    "#0099FF",
    "#0099CC",
    "#009999",
    "#009966",
    "#009933",
    "#009900",
    "#0066FF",
    "#0066CC",
    "#006699",
    "#006666",
    "#006633",
    "#006600",
    "#0033FF",
    "#0033CC",
    "#003399",
    "#003366",
    "#003333",
    "#003300",
    "#0000FF",
    "#0000CC",
    "#000099",
    "#000066",
    "#000033",
    "#EE0000",
    "#DD0000",
    "#BB0000",
    "#AA0000",
    "#880000",
    "#770000",
    "#550000",
    "#440000",
    "#220000",
    "#110000",
    "#00EE00",
    "#00DD00",
    "#00BB00",
    "#00AA00",
    "#008800",
    "#007700",
    "#005500",
    "#004400",
    "#002200",
    "#001100",
    "#0000EE",
    "#0000DD",
    "#0000BB",
    "#0000AA",
    "#000088",
    "#000077",
    "#000055",
    "#000044",
    "#000022",
    "#000011",
    "#EEEEEE",
    "#DDDDDD",
    "#BBBBBB",
    "#AAAAAA",
    "#888888",
    "#777777",
    "#555555",
    "#444444",
    "#222222",
    "#111111",
    "#000000"
]

assert len(colours) == 256
numHeight = 16
numWidth = int(len(colours) / numHeight)
squareWidth = float(canvas[0]) / float(numWidth)
squareHeight = float(canvas[1]) / float(numHeight)
# draw rectangles
for i in range(numWidth*numHeight):
    currentWidth = i % numWidth
    currentHeight = int(i / numWidth)
    xPos = currentWidth * squareWidth
    yPos = currentHeight * squareHeight
    draw.rectangle([xPos, yPos, xPos + squareWidth, yPos + squareHeight], fill=colours[i])

'''
debugX=0.96875
debugY=0.3125
debugBoxSize=(currentWidth*0.2)/2
debugX = debugX * 1920
debugY = debugY * 1080
draw.rectangle([debugX-debugBoxSize, debugY-debugBoxSize, debugX+debugBoxSize, debugY+debugBoxSize], fill="#000000")
'''

# make thumbnail
im.thumbnail(canvas)

# save image
im.save(outPath)