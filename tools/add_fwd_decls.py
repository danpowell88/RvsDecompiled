"""Add forward declarations for undefined types referenced by auto-generated method declarations."""

HEADER = 'src/engine/EngineClasses.h'

FORWARD_DECLS = """\
// Forward declarations for auto-generated method parameters
struct FProjectorRenderInfo;
class MdtBaseConstraint;
struct MotionChunk;
class UDemoRecDriver;
struct FSpriteParticleVertex;
enum eDecalType : int;

"""

with open(HEADER) as f:
    content = f.read()

# Insert after the first #include or #pragma line, or at the very top
# Find the position after the last existing #include/#pragma
lines = content.split('\n')
insert_after = 0
for i, line in enumerate(lines):
    if line.startswith('#include') or line.startswith('#pragma'):
        insert_after = i + 1

# Insert forward declarations
lines.insert(insert_after, FORWARD_DECLS)
content = '\n'.join(lines)

with open(HEADER, 'w') as f:
    f.write(content)

print(f"Added forward declarations after line {insert_after}")
