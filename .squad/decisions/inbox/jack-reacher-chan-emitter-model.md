## Jack Reacher — IMPL classification notes (UnChan / UnEmitter / UnModel)

### Scope reviewed
- `src/Engine/Src/UnChan.cpp`
  - `UActorChannel::ReceivedBunch` (`0x104827f0`)
  - `UActorChannel::ReplicateActor` (`0x104834d0`)
- `src/Engine/Src/UnEmitter.cpp`
  - `UParticleEmitter::UpdateParticles` (`0x103ddca0`)
- `src/Engine/Src/UnModel.cpp`
  - `UModel::Render` (`0x103cd750`)

### Decision summary
- Kept all four functions as `IMPL_TODO`.
- Did **not** promote to `IMPL_DIVERGE`: no permanent external blocker (no GameSpy/Karma-only/rdtsc-only constraint for these specific bodies).
- Did **not** promote to `IMPL_MATCH`: each still has substantial unresolved helper/layer reconstruction risk.

### Evidence used
- Ground truth decomp from `ghidra/exports/Engine/_global.cpp` (address-tagged extracts).
- SDK cross-check in `sdk/Raven_Shield_C_SDK/432Core/Inc/UnCoreNet.h` for `FFieldNetCache`/`FClassNetCache`.

### Rationale by function
1) `UActorChannel::ReceivedBunch` (`0x104827f0`)
- Large mixed flow (actor open, property stream, RPC decode, role swap, post-net paths).
- `FFieldNetCache` layout itself is available; unresolved parts are helper mappings and exact call order.
- Classification: `IMPL_TODO` (temporary, implementable with more mapping work).

2) `UActorChannel::ReplicateActor` (`0x104834d0`)
- Full send pipeline includes dirty gather, retire merge, per-field mark/rollback, and conditional actor flag state.
- Depends on several unresolved helpers and precise sequencing that should not be guessed.
- Classification: `IMPL_TODO`.

3) `UParticleEmitter::UpdateParticles` (`0x103ddca0`)
- Early update/lifetime loop already implemented.
- Remaining collision/bounce/force/ramp sections still need validated layout + helper mapping.
- Classification: `IMPL_TODO`.

4) `UModel::Render` (`0x103cd750`)
- Confirmed as a broad render dispatcher with many helper dependencies in unnamed render paths.
- Tractable but not yet safe to claim parity without further helper naming/reconstruction.
- Classification: `IMPL_TODO`.
