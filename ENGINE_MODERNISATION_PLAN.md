# Plan: Ravenshield Engine Full Modernization

Modernize the decompiled Ravenshield engine (Unreal Engine 2.x, 2003) for maximum graphical fidelity — replacing rendering (D3D8→modern), audio (DARE→modern), physics (Karma→modern), and video (Bink→FFmpeg), plus AI-powered asset upscaling pipelines for textures, audio, video, and meshes.

**Key architectural insight**: The engine has a **pluggable render device** (`URenderDevice`) and **pluggable audio subsystem** (`UAudioSubsystem`), making renderer and audio swaps straightforward. Physics (Karma) is **baked directly into `AActor`** with 100+ exec functions — this is the hardest part.

---

### Current Engine State

| Subsystem | Current Tech | Pluggable? | Replacement Difficulty |
|-----------|-------------|------------|----------------------|
| Rendering | Direct3D 8, PS 1.x-2.0 | Yes (`URenderDevice`) | Easy — factory pattern |
| Audio | DARE (DirectSound3D + OpenAL + EAX) | Yes (`UAudioSubsystem`) | Medium |
| Physics | Karma middleware | No — baked into `AActor` | **Hard** — major refactor |
| Video | Bink (`binkw32.dll`) | Partial (5 methods on render device) | Medium |

### Asset Inventory

- ~90 texture packages (.utx) — DXT1/3/5, P8, BGRA8
- ~29 static mesh packages (.usx)
- ~14 skeletal mesh/animation packages (.ukx)
- ~450+ sound packages (.uax + .SB0/.SS0 DARE banks)
- 18 Bink videos (.bik)
- ~30 maps (.rsm)

---

## Phase M1: Modern Rendering Backend (D3D8 → bgfx)

**Tech: [bgfx](https://github.com/bkaradzic/bgfx) (BSD-2-Clause, FREE)**
Cross-platform rendering library supporting D3D11, D3D12, Vulkan, Metal, OpenGL. Used in commercial games, active development, handles shader compilation and draw call batching.

**Steps:**

1. **M1.1 — Rendering abstraction** (*no deps*): Create `src/bgfxdrv/` with `UBgfxRenderDevice : URenderDevice`. Implement `Init()`, `SetRes()`, `Lock()/Unlock()`, `Present()`, `Flush()`, `ReadPixels()`. Support all `ETextureFormat` values (DXT1/3/5, BGRA8, P8, L8). Config-switchable via `RenderDevice=BgfxDrv.BgfxRenderDevice` in INI.
2. **M1.2 — Feature parity** (*depends on M1.1*): Texture upload, static mesh rendering, skeletal mesh rendering, BSP/level geometry, basic vertex lighting, Canvas 2D (HUD/menus), cubemaps.
3. **M1.3 — Modern graphics** (*depends on M1.2*): PBR material pipeline (reinterpret UShader/UModifier as roughness/metallic/normal), HDR with tone mapping, cascaded shadow maps, SSAO (GTAO), HDR bloom, FXAA/TAA, normal mapping, per-pixel dynamic lighting, volumetric fog, screen-space reflections.
4. **M1.4 — Post-processing** (*depends on M1.3*): Configurable post-process chain (film grain, vignette, color grading LUT, depth of field for scopes, night vision phosphor shader, optional motion blur).

**Relevant files:** `src/D3DDrv/D3DDrv.cpp`, `src/Engine/UnRender.cpp`, `src/Engine/EngineClasses.h`, `src/Engine/UnMaterial.cpp`

---

## Phase M2: Modern Audio (DARE → OpenAL Soft + Steam Audio)

**Tech: [OpenAL Soft](https://openal-soft.org/) (LGPL, FREE) + [Steam Audio](https://valvesoftware.github.io/steam-audio/) (FREE)**
OpenAL Soft is a drop-in for the existing OpenAL32.dll reference with HRTF support. Steam Audio adds physics-based reverb, occlusion, and binaural rendering — all free.

**Steps:**

1. **M2.1 — OpenAL Soft core** (*no deps*): Create `src/openaldrv/` with `UOpenALAudioSubsystem`. Decode .uax → PCM → OpenAL buffers. 3D positional audio, HRTF, music playback via stb_vorbis.
2. **M2.2 — Steam Audio spatial** (*depends on M2.1*): Physics-based propagation using BSP room geometry, real-time occlusion through walls/doors, material-based acoustics (concrete vs metal vs wood), binaural headphone rendering.
3. **M2.3 — Enhancement features** (*depends on M2.1*): EAX replacement via Steam Audio reverb zones, configurable voice count (>20), distance-based low-pass filtering, Doppler.

**Relevant files:** `src/DareAudio/`, `src/Engine/UnAudio.cpp`, `retail/system/DARE.INI`

---

## Phase M3: Modern Physics (Karma → Jolt Physics)

**Tech: [Jolt Physics](https://github.com/jrouwe/JoltPhysics) (MIT, FREE)**
Used by Horizon Forbidden West. Excellent ragdoll, constraints, character controller. Modern C++17.

**⚠️ HIGHEST RISK — Karma is baked directly into AActor with 100+ native functions**

**Steps:**

1. **M3.1 — Physics abstraction** (*parallel with M1/M2*): Create `src/physics/` with abstract `IPhysicsWorld`, `IPhysicsBody`, `IPhysicsConstraint`. Map `UKarmaParams` → body descriptors, `AKConstraint/AKHinge/AKBSJoint/AKConeLimit` → constraint types. Implement `JoltPhysicsWorld`.
2. **M3.2 — Actor integration refactor** (*depends on M3.1*): Redirect `AActor::physKarma()`, `physKarmaRagDoll()`, and all 100+ `execK*` native functions through the abstraction. Character physics (`physFalling`, `physFlying`, `physLadder`) → Jolt character controller. `physProjectile` → Jolt ray/shape cast.
3. **M3.3 — Ragdoll system** (*depends on M3.2*): Convert skeletal bone hierarchies to Jolt ragdoll descriptions, map `UKarmaParamsSkel` constraints, implement death→ragdoll transitions.
4. **M3.4 — Constraint objects** (*depends on M3.2*): Door hinges, breakable constraints, interactive objects, ladders.

**Relevant files:** `src/Engine/UnActor.cpp` (100+ execK* functions), `src/Engine/UnPawn.cpp`, `src/Engine/EngineClasses.h` (AKActor, UKarmaParams)

---

## Phase M4: Modern Video (Bink → FFmpeg)

**Tech: [FFmpeg](https://ffmpeg.org/) libavcodec/libavformat (LGPL, FREE)**

**Steps:**

1. **M4.1 — FFmpeg integration** (*no deps*): Create `src/ffmpegvideo/`. Decode video frames → texture. Wire into render device `OpenVideo()/DisplayVideo()/StopVideo()/CloseVideo()`. Sync audio track.
2. **M4.2 — HD video support** (*depends on M4.1*): Support H.264/H.265 .mp4 files. Fallback chain: look for `{name}.mp4`, then `{name}.bik`.

**Relevant files:** `src/D3DDrv/D3DDrv.cpp` (Bink integration), `retail/Videos/` (18 .bik files)

---

## Phase M5: AI Texture Upscaling Pipeline

**Goal:** 4x upscale all textures (~256×256 → 1024×1024+) + generate PBR material maps.

| Tool | Cost | Purpose |
|------|------|---------|
| **[Upscayl](https://upscayl.org/)** | FREE (AGPL) | GUI batch upscaling (Real-ESRGAN) |
| **[Real-ESRGAN-ncnn-vulkan](https://github.com/xinntao/Real-ESRGAN-ncnn-vulkan)** | FREE (BSD-3) | CLI GPU-accelerated batch upscaling |
| **4x-UltraSharp model** | FREE | Best ESRGAN model for game textures |
| **[chaiNNer](https://chainner.app/)** | FREE (MIT) | Node pipeline: upscale → sharpen → denoise |
| **[Materialize](http://boundingboxsoftware.com/materialize/)** | FREE (MIT) | Generate PBR maps (normal, roughness, AO) from diffuse |
| **GIMP + G'MIC** | FREE (GPL) | Manual touch-up |
| *Topaz Gigapixel AI* | *~$100* | *Better on character faces — optional* |

**Steps:**

1. **M5.1 — Extract**: UModel batch-extract all ~90 .utx → PNG. Catalog by category (world, character, UI, normal, alpha).
2. **M5.2 — Batch upscale**: Python script routing to appropriate model (UltraSharp for world/character, AnimeSharp for UI). Real-ESRGAN-ncnn on GPU. ~2-4 hours total.
3. **M5.3 — PBR generation**: Materialize on upscaled diffuse → normal, roughness, AO, height maps.
4. **M5.4 — Review & fix**: Visual comparison tool. Manual fixes for AI artifacts on hero textures.
5. **M5.5 — Repackage**: Back to .utx or loose file loading with PBR override system (`{name}_normal.dds`, `{name}_roughness.dds`).

---

## Phase M6: AI Audio Enhancement Pipeline

| Tool | Cost | Purpose |
|------|------|---------|
| **[Resemble Enhance](https://github.com/resemble-ai/resemble-enhance)** | FREE (MIT) | Speech denoising + enhancement |
| **[AudioSR](https://github.com/haoheliu/versatile_audio_super_resolution)** | FREE (MIT) | Audio super-resolution (16kHz→48kHz) |
| **[Adobe Podcast Enhance](https://podcast.adobe.com/enhance)** | FREE tier | Cloud voice enhancement (best quality) |
| **[Demucs](https://github.com/facebookresearch/demucs)** | FREE (MIT) | Source separation |
| **Audacity** | FREE (GPL) | Manual editing |
| *iZotope RX* | *~$400* | *Industry standard — optional* |

**Steps:**

1. **M6.1 — Extract**: All .uax → WAV via UModel. Catalog: weapons, foley, ambience, voice, music.
2. **M6.2 — Voice enhancement**: Resemble Enhance on ~200 voice packages. Adobe Podcast for Clark briefings.
3. **M6.3 — Weapon/SFX**: AudioSR bandwidth extension. Preserve transients.
4. **M6.4 — Ambience/Music**: Light AudioSR pass. Re-encode higher bitrate.
5. **M6.5 — Repackage**: Back to .uax or loose WAV/OGG loading.

---

## Phase M7: AI Video Upscaling Pipeline

| Tool | Cost | Purpose |
|------|------|---------|
| **[Video2X](https://github.com/k4yt3x/video2x)** | FREE (MIT) | Video upscaling pipeline |
| **Real-ESRGAN-ncnn-vulkan** | FREE | Frame-by-frame upscaling |
| **[RIFE](https://github.com/hzwer/ECCV2022-RIFE)** | FREE (MIT) | Frame interpolation (24→60fps) |
| **FFmpeg** | FREE (LGPL) | Frame extraction/reassembly |
| ***[Topaz Video AI](https://www.topazlabs.com/topaz-video-ai)*** | ***~$200*** | ***Strongly recommended — dramatically better temporal coherence than free options*** |

**Steps:**

1. **M7.1 — Extract**: FFmpeg extract .bik → frames + audio.
2. **M7.2 — Upscale**: Video2X + Real-ESRGAN 4x (free) OR Topaz Video AI Proteus (paid, much better). Target 1080p.
3. **M7.3 — Interpolation** (optional): RIFE 24→60fps on cutscenes.
4. **M7.4 — Re-encode**: H.264/H.265 .mp4. Mux enhanced audio from M6.

---

## Phase M8: Mesh Enhancement

| Tool | Cost | Purpose |
|------|------|---------|
| **[Blender](https://www.blender.org/)** | FREE (GPL) | Mesh editing, subdivision, baking |
| **[Instant Meshes](https://github.com/wjakob/instant-meshes)** | FREE (BSD) | Auto-retopology |
| **[xNormal](https://xnormal.net/)** | FREE | Normal map baking |

**Steps:**

1. **M8.1 — Extract**: UModel extract .usx/.ukx → glTF/PSK.
2. **M8.2 — Static meshes**: Priority: weapons, interactive objects, key geometry. Subdivide → sculpt detail → retopologize → bake normals.
3. **M8.3 — Skeletal meshes**: Character models with bone weight preservation. First-person weapons highest priority.
4. **M8.4 — LOD generation**: New LOD chain from enhanced meshes. Blender decimate or Simplygon (free non-commercial).

---

## Phase M9: Build System & Integration

**Steps:**

1. **M9.1 — CMake modernization** (*parallel*): MSVC 2022 / C++17 preset. New modules: `BgfxDrv`, `OpenALDrv`, `Physics`, `FFmpegVideo`. vcpkg manifest for dependencies.
2. **M9.2 — Runtime configuration** (*depends on M1.1*): INI-based quality presets (Low=D3D8 parity, Medium, High, Ultra). Backend selection for audio, physics, video. Texture quality toggle (Original / HD / PBR).
3. **M9.3 — Asset loading modernization** (*depends on M1.2*): Loose file loading alongside .utx/.usx packages. PBR material override system. HD texture pack as optional download.

---

## Dependency Graph

```
M1 (Rendering)  ─────────────────┐
M2 (Audio)       ───── parallel ──┤
M3 (Physics)     ───── parallel ──┤──→ M9 (Integration & Config)
M4 (Video)       ───── parallel ──┤
                                  │
M5 (Texture Upscale) ─ parallel ──┤
M6 (Audio Upscale)   ─ parallel ──┤
M7 (Video Upscale)   ─ parallel ──┤
M8 (Mesh Enhancement) ─ parallel ─┘
```

- M1–M4 (engine) can run in parallel — separate modules
- M5–M8 (assets) can run in parallel with each other AND with engine work
- M3 (Physics) is the longest — start early
- **All asset pipelines are independent of engine work** — can start immediately

---

## Cost Summary

| Tier | Cost | What you get |
|------|------|-------------|
| **All free** | **$0** | Everything above using free tools only |
| **Recommended paid** | **~$300** | + Topaz Video AI ($200) + Topaz Gigapixel ($100) for dramatically better video upscaling and character texture quality |
| **Premium** | **~$700** | + iZotope RX ($400) for professional audio restoration |

---

## Verification

1. Side-by-side screenshots every map: D3D8 vs bgfx — all geometry, textures, lighting correct
2. A/B audio test: 20 sounds per category. Spatial audio in 5.1 and headphone
3. Ragdoll comparison: record 50 deaths original vs Jolt. Door/constraint interactions functional
4. All 18 cutscenes play correctly, no desync
5. In-game comparison tool: original vs upscaled textures
6. 60fps at 1080p on mid-range GPU (RTX 3060 class) with all enhancements
7. Full campaign playthrough (15 missions + training) with all modernized subsystems
8. Build succeeds with both MSVC 7.1 (legacy) and MSVC 2022 (modern) presets

---

## Decisions

- **Legacy preserved**: Original D3D8/DARE/Karma paths kept as fallback — modernization is additive
- **Rendering approach**: Forward+ (clustered forward) over deferred — simpler, MSAA-friendly, matches original approach
- **HD assets as optional pack**: ~10-20GB separately downloadable, INI toggle
- **Shader language**: bgfx shading language for cross-platform
- **Ray tracing**: Out of scope (bgfx supports it but requires significant work)
- **No gameplay changes**: AI behavior, weapon balance, game modes untouched

---

## Further Considerations

1. **Deferred vs Forward rendering?** Recommendation: Forward+ unless >50 dynamic lights are needed per scene
2. **Asset pack distribution**: HD textures could be 10–20GB — recommend optional separate download with INI toggle
3. **Community mods**: OpenRVS and existing mods must still work — modernized subsystems should gracefully fall back for unenhanced content
