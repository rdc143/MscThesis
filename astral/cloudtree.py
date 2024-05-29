import toytree
import toyplot
import numpy as np
import toyplot.pdf

trees = toytree.mtree("../raxml/100k/100k.tre")

#trees = toytree.mtree(trees.treelist[:100])


cons = trees.get_consensus_tree().root("TstrZam_0843.Cattle.bam")


canvas, axes, mark = trees.draw_cloud_tree(
    fixed_order=cons.get_tip_labels(),
    height=800,
    width=800,
    use_edge_lengths=False,
    jitter=0.05,
    edge_style={
        'stroke': toyplot.color.brewer.palette("BlueGreen")[4],
        'stroke-opacity': 0.03,
        "stroke-width": 2
    },
    tip_labels=False
)

#print(trees.draw_cloud_tree.__code__.co_varnames)
#print(trees.draw_cloud_tree.__code__

cons.draw(
    axes=axes,  # Use the same axes as the cloud tree
    tip_labels=cons.get_tip_labels(),  # Make sure the tip labels match for consistent order
    edge_colors="black",  # Change to the desired color
    edge_widths=2,
    use_edge_lengths=False,
    edge_type='c'
)
toyplot.pdf.render(canvas, "./cloudtree100k.pdf")


canvas, axes, mark = cons.draw(node_labels='support', use_edge_lengths=False, node_sizes=16);

toyplot.pdf.render(canvas, "./consensustree100k.pdf")

canvas, axes, mark = trees.draw(
    nrows=5,
    ncols=5,
    height=800,
    width=1200,
    fixed_order=cons.get_tip_labels(),
    #use_edge_lengths=False,
    shared_axes=True,
)

toyplot.pdf.render(canvas, "./trees100k.pdf")
