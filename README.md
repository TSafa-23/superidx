# superiDX (superiNDexer)
A custom made mod for super efficient custom schematic storage using an index table.

# How it works
It works by using a large table of indexes which belong to another table with the nodes. It's fairly similar to how MT handles nodes.

# Why it's better
It's better as it uses the traditional voxel ideology of nodes beloning to a position, not the other way around. This way, no hard coordinates have to be set and the table is spliced by LWH values. Because of no hard positions, it also saves an enourmous amount of space, up to 24 times more efficient than worldedit schematics.

# To do/wishlist
Proper schematic saving
Schematic optimization
LVM Placement (currently unworking/slower)
