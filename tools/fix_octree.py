"""Change struct FOctreeNode and struct FCollisionOctree to class 
to match retail name mangling (V prefix instead of U)."""

PATH = r"c:\Users\danpo\Desktop\rvs\src\engine\EngineClasses.h"

with open(PATH, 'r') as f:
    content = f.read()

# Change FCollisionOctree from struct to class
old1 = "struct ENGINE_API FCollisionOctree : public FCollisionHashBase\n{\npublic:"
new1 = "class ENGINE_API FCollisionOctree : public FCollisionHashBase\n{\npublic:"
if old1 in content:
    content = content.replace(old1, new1)
    print("Changed FCollisionOctree from struct to class")
else:
    print("FCollisionOctree pattern not found!")

# Change FOctreeNode from struct to class
old2 = "struct ENGINE_API FOctreeNode\n{"
new2 = "class ENGINE_API FOctreeNode\n{\npublic:"
if old2 in content:
    content = content.replace(old2, new2)
    print("Changed FOctreeNode from struct to class")
else:
    print("FOctreeNode pattern not found!")

with open(PATH, 'w') as f:
    f.write(content)

print("Done!")
