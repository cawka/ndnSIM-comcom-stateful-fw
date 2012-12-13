#!/usr/bin/python

import argparse
import sys
from pyx import *

parser = argparse.ArgumentParser (description="CCNx grapher")
parser.add_argument ("input", metavar="<input>", 
                     help="Input log file")

parser.add_argument ("output", metavar="<output>", 
                     help="Output PDF file",
                     default="out.pdf")
args = parser.parse_args ()

input_interests = graph.data.file (args.input, title="Interests (in)", xname="int(Node), 0", y="InInterests");
input_nacks     = graph.data.file (args.input, title="NACKs (in)",     xname="int(Node), 1", y="InNacks");
input_data      = graph.data.file (args.input, title="Data (in)",      xname="int(Node), 2", y="InData");

unit.set(defaultunit="inch")
text.set(mode="latex", docopt="12pt")
text.preamble(r"\parindent0ex")

g = graph.graphxy (
    width = 10, height = 6,
    key = graph.key.key (),
    x=graph.axis.nestedbar (title="Node", dist=1),
    y=graph.axis.linear (title="Number of packets"))

g.plot ([input_interests],
        [graph.style.bar ([color.cmyk.Apricot])])

g.plot ([input_nacks],
        [graph.style.bar ([color.cmyk.DarkOrchid])])

g.plot ([input_data],
        [graph.style.bar ([color.cmyk.PineGreen])])

# [color.cmyk.Apricot,color.cmyk.DarkOrchid,color.cmyk.PineGreen], 
        # [
        #  graph.style.stackedbarpos("InInterests"),
        #  graph.style.bar([color.cmyk.Apricot]),
        #  graph.style.stackedbarpos("OutInterests"),
        #  graph.style.bar([color.rgb.green]),
        #  # graph.style.text ("y"),
        #  # graph.style.stackedbarpos("OutInterests"),
        #  # graph.style.bar([color.rgb.green]),
        #  # graph.style.text ("outi")
        #  ])

# g.plot (input, [graph.style.bar([color.cmyk.Apricot])])

g.writePDFfile (args.output)

sys.exit ()

# g = graph.graphxy(
#     width=4, height=2,
#     x=graph.axis.nestedbar(
#         dist=0.4,
#         title="Node number",
#         ),
#     y=graph.axis.linear(
#         title="Mean opinion score (MOS)",
#         painter=graph.axis.painter.regular(innerticklength=graph.axis.painter.ticklength(0.12 * unit.v_cm,0))),
#     y2=None,
#     x2=None,


# g.plot(graph.data.points([
# 	((0,"Normal"),4.105263158, 0.657836255),
# 	((0,"2\% loss"),2.736842105, 0.733492806),
# 	((0,"10\% loss"), 1.210526316, 0.418853908)], xname=1, y=2, dy=3), [graph.style.bar([color.cmyk.Apricot]), graph.style.errorbar()])

# g.plot(graph.data.points([
# 	((1,"Normal"),3.7, 0.9),
# 	((1,r"\parbox[t]{2cm}{\centering Periodic \\ throttling}"),1, 0)
# 	], xname=1, y=2, dy=3), [graph.style.bar([color.cmyk.Red]), graph.style.errorbar()])

# g.draw(path.rect(0, 0, 4, 1.2), [deco.filled([color.cmyk.Green, color.transparency(0.8)]), deco.stroked(), style.linestyle.dashed])


# g.text(1, 1.8, r"\Large UDP", [text.halign.boxcenter])
# g.text(3.3, 1.8, r"\Large TCP", [text.halign.boxcenter])


# g.text(2, 1, r"Unacceptable quality", [text.halign.boxcenter])

# # g.plot(graph.data.points([
# # 	((0, "No loss"), 5),
# # 	((0, "5% loss"), 6),
# # 	((0, "10% loss"), 1),
# # 	((1, "No loss"), 5),
# # 	((1, "Dissuade"), 1)], xname=1, y=2), [graph.style.bar()])

# # g.plot(graph.data.points([
# # 	((0, "No loss"), 5),
# # 	((0, "5% loss"), 6),
# # 	((0, "10% loss"), 1),
# # 	((1, "No loss"), 5),
# # 	((1, "Dissuade"), 1)], xname=1, y=2), [graph.style.bar()])

# # g = graph.graphxy(width=8, x=graph.axis.split())
# # g.plot(graph.data.points([((0, 0.1), 0.1),
# #                           ((0, 0.5), 0.2),
# #                           ((0, 0.9), 0.3),
# #                           ((1, 101), 0.7),
# #                           ((1, 105), 0.8),
# #                           ((1, 109), 0.9)], x=1, y=2))
	
# 	# "file("minimal.dat", xname="$1, 0", y=2),
# 	#     graph.data.file("minimal.dat", xname="$1, 1", y=3)],
# 	#    [graph.style.bar()])
# g.writePDFfile (out)
