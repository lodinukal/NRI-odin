// © 2021 NVIDIA Corporation

/*
Overview:
- Generalized common denominator for VK, D3D12 and D3D11
    - VK spec: https://registry.khronos.org/vulkan/specs/latest/html/vkspec.html
       - Best practices: https://developer.nvidia.com/blog/vulkan-dos-donts/
       - Feature support coverage: https://vulkan.gpuinfo.org/
    - D3D12 spec: https://microsoft.github.io/DirectX-Specs/
       - Feature support coverage: https://d3d12infodb.boolka.dev/
    - D3D11 spec: https://microsoft.github.io/DirectX-Specs/d3d/archive/D3D11_3_FunctionalSpec.htm

Goals:
- generalization and unification of D3D12 and VK
- explicitness (providing access to low-level features of modern GAPIs)
- quality-of-life and high-level extensions (e.g., streaming and upscaling)
- low overhead
- cross-platform and platform independence (AMD/INTEL friendly)
- D3D11 support (as much as possible)

Non-goals:
- exposing entities not existing in GAPIs
- high-level (D3D11-like) abstraction
- hidden management of any kind (except for some high-level extensions where it's desired)
- automatic barriers (better handled in a higher-level abstraction)

Thread safety:
- Threadsafe: yes - free-threaded access
- Threadsafe: no  - external synchronization required, i.e. one thread at a time (additional restrictions can apply)
- Threadsafe: ?   - unclear status

Implicit:
- Create*         - thread safe
- Destroy*        - not thread safe (because of VK)
- Cmd*            - not thread safe
*/
package NRI

import "core:c"

when ODIN_DEBUG {
	@(private = "file")
	lib_path :: "./lib/debug/"
} else {
	@(private = "file")
	lib_path :: "./lib/release/"
}

when ODIN_OS == .Windows {
	when ODIN_ARCH == .amd64 {
		foreign import lib {lib_path + "x86_64-windows.lib", "system:dxgi.lib", "system:dxguid.lib", "system:d3d12.lib", "system:d3d11.lib", "system:User32.lib"}
	} else when ODIN_ARCH == .arm64 {
		foreign import lib {lib_path + "aarch64-windows.lib"}
	} else do #panic("Unsupported architecture")
} else when ODIN_OS == .Darwin {
	when ODIN_ARCH == .arm64 {
		foreign import lib {lib_path + "libaarch64-macos.a"}
	} else do #panic("Unsupported architecture")
} else when ODIN_OS == .Linux {
	when ODIN_ARCH == .amd64 {
		foreign import lib {lib_path + "libx86_64-linux.a"}
	} else when ODIN_ARCH == .arm64 {
		foreign import lib {lib_path + "libaarch64-linux.a"}
	} else do #panic("Unsupported architecture")
} else do #panic("Unsupported OS")

NRI_VERSION :: 177
NRI_VERSION_DATE :: "31 October 2025"

@(default_calling_convention = "c", link_prefix = "nri")
foreign lib {
	// Example: Result result = nriGetInterface(device, NRI_INTERFACE(CoreInterface), &coreInterface)
	GetInterface :: proc(device: ^Device, interfaceName: cstring, interfaceSize: c.size_t, interfacePtr: rawptr) -> Result ---

	// Annotations for profiling tools: host
	// - Host annotations currently use NVTX (NVIDIA Nsight Systems)
	// - Device (command buffer and queue) annotations use GAPI or PIX (if "WinPixEventRuntime.dll" is nearby)
	// - Colorization requires PIX or NVTX
	BeginAnnotation :: proc(name: cstring, bgra: u32) --- // start a named range
	EndAnnotation :: proc() --- // end the last opened range
	Annotation :: proc(name: cstring, bgra: u32) --- // emit a named simultaneous event
	SetThreadName :: proc(name: cstring) --- // assign a name to the current thread
}

// Threadsafe: yes
CoreInterface :: struct {
	// Get
	GetDeviceDesc:                proc "c" (device: ^Device) -> ^DeviceDesc,
	GetBufferDesc:                proc "c" (buffer: ^Buffer) -> ^BufferDesc,
	GetTextureDesc:               proc "c" (texture: ^Texture) -> ^TextureDesc,
	GetFormatSupport:             proc "c" (device: ^Device, format: Format) -> FormatSupportBits,
	GetQuerySize:                 proc "c" (queryPool: ^QueryPool) -> u32,
	GetFenceValue:                proc "c" (fence: ^Fence) -> u64,

	// Returns one of the pre-created queues (see "DeviceCreationDesc" or wrapper extensions)
	// Return codes: "UNSUPPORTED" (no queues of "queueType") or "INVALID_ARGUMENT" (if "queueIndex" is out of bounds).
	// Getting "COMPUTE" and/or "COPY" queues switches VK sharing mode to "VK_SHARING_MODE_CONCURRENT" for resources created without "queueExclusive" flag.
	// This approach is used to minimize number of "queue ownership transfers", but also adds a requirement to "get" all async queues BEFORE creation of
	// resources participating into multi-queue activities. Explicit use of "queueExclusive" removes any restrictions.
	GetQueue:                     proc "c" (
		device: ^Device,
		queueType: QueueType,
		queueIndex: u32,
		queue: ^^Queue,
	) -> Result,

	// Create (doesn't assume allocation of big chunks of memory on the device, but it happens for some entities implicitly)
	CreateCommandAllocator:       proc "c" (
		queue: ^Queue,
		commandAllocator: ^^CommandAllocator,
	) -> Result,
	CreateCommandBuffer:          proc "c" (
		commandAllocator: ^CommandAllocator,
		commandBuffer: ^^CommandBuffer,
	) -> Result,
	CreateFence:                  proc "c" (
		device: ^Device,
		initialValue: u64,
		fence: ^^Fence,
	) -> Result,
	CreateDescriptorPool:         proc "c" (
		device: ^Device,
		descriptorPoolDesc: ^DescriptorPoolDesc,
		descriptorPool: ^^DescriptorPool,
	) -> Result,
	CreatePipelineLayout:         proc "c" (
		device: ^Device,
		pipelineLayoutDesc: ^PipelineLayoutDesc,
		pipelineLayout: ^^PipelineLayout,
	) -> Result,
	CreateGraphicsPipeline:       proc "c" (
		device: ^Device,
		graphicsPipelineDesc: ^GraphicsPipelineDesc,
		pipeline: ^^Pipeline,
	) -> Result,
	CreateComputePipeline:        proc "c" (
		device: ^Device,
		computePipelineDesc: ^ComputePipelineDesc,
		pipeline: ^^Pipeline,
	) -> Result,
	CreateQueryPool:              proc "c" (
		device: ^Device,
		queryPoolDesc: ^QueryPoolDesc,
		queryPool: ^^QueryPool,
	) -> Result,
	CreateSampler:                proc "c" (
		device: ^Device,
		samplerDesc: ^SamplerDesc,
		sampler: ^^Descriptor,
	) -> Result,
	CreateBufferView:             proc "c" (
		bufferViewDesc: ^BufferViewDesc,
		bufferView: ^^Descriptor,
	) -> Result,
	CreateTexture1DView:          proc "c" (
		textureViewDesc: ^Texture1DViewDesc,
		textureView: ^^Descriptor,
	) -> Result,
	CreateTexture2DView:          proc "c" (
		textureViewDesc: ^Texture2DViewDesc,
		textureView: ^^Descriptor,
	) -> Result,
	CreateTexture3DView:          proc "c" (
		textureViewDesc: ^Texture3DViewDesc,
		textureView: ^^Descriptor,
	) -> Result,

	// Destroy
	DestroyCommandAllocator:      proc "c" (commandAllocator: ^CommandAllocator),
	DestroyCommandBuffer:         proc "c" (commandBuffer: ^CommandBuffer),
	DestroyDescriptorPool:        proc "c" (descriptorPool: ^DescriptorPool),
	DestroyBuffer:                proc "c" (buffer: ^Buffer),
	DestroyTexture:               proc "c" (texture: ^Texture),
	DestroyDescriptor:            proc "c" (descriptor: ^Descriptor),
	DestroyPipelineLayout:        proc "c" (pipelineLayout: ^PipelineLayout),
	DestroyPipeline:              proc "c" (pipeline: ^Pipeline),
	DestroyQueryPool:             proc "c" (queryPool: ^QueryPool),
	DestroyFence:                 proc "c" (fence: ^Fence),

	// Memory
	AllocateMemory:               proc "c" (
		device: ^Device,
		allocateMemoryDesc: ^AllocateMemoryDesc,
		memory: ^^Memory,
	) -> Result,
	FreeMemory:                   proc "c" (memory: ^Memory),

	// Resources and memory (VK style)
	//  - create a resource (buffer or texture)
	//  - use "Get[Resource]MemoryDesc" to get "MemoryDesc" ("usageBits" and "MemoryLocation" affect returned "MemoryType")
	//  - (optional) group returned "MemoryDesc"s by "MemoryType", but don't group if "mustBeDedicated = true"
	//  - (optional) sort returned "MemoryDesc"s by alignment
	//  - call "AllocateMemory" (even if "mustBeDedicated = true")
	//  - call "Bind[Resource]Memory" to bind resources to "Memory" objects
	//  - (optional) "CalculateAllocationNumber" and "AllocateAndBindMemory" from "NRIHelper" interface simplify this process for buffers and textures
	CreateBuffer:                 proc "c" (
		device: ^Device,
		bufferDesc: ^BufferDesc,
		buffer: ^^Buffer,
	) -> Result,
	CreateTexture:                proc "c" (
		device: ^Device,
		textureDesc: ^TextureDesc,
		texture: ^^Texture,
	) -> Result,
	GetBufferMemoryDesc:          proc "c" (
		buffer: ^Buffer,
		memoryLocation: MemoryLocation,
		memoryDesc: ^MemoryDesc,
	),
	GetTextureMemoryDesc:         proc "c" (
		texture: ^Texture,
		memoryLocation: MemoryLocation,
		memoryDesc: ^MemoryDesc,
	),
	BindBufferMemory:             proc "c" (
		bindBufferMemoryDescs: ^BindBufferMemoryDesc,
		bindBufferMemoryDescNum: u32,
	) -> Result,
	BindTextureMemory:            proc "c" (
		bindTextureMemoryDescs: ^BindTextureMemoryDesc,
		bindTextureMemoryDescNum: u32,
	) -> Result,

	// Resources and memory (D3D12 style)
	// - "Get[Resource]MemoryDesc2" requires "maintenance4" support on Vulkan
	// - "memory, offset" pair can be replaced with a "Nri[Device/DeviceUpload/HostUpload/HostReadback]Heap" macro to create a placed resource in the corresponding memory using VMA (AMD Virtual Memory Allocator) implicitly
	GetBufferMemoryDesc2:         proc "c" (
		device: ^Device,
		bufferDesc: ^BufferDesc,
		memoryLocation: MemoryLocation,
		memoryDesc: ^MemoryDesc,
	), // requires "features.getMemoryDesc2"
	GetTextureMemoryDesc2:        proc "c" (
		device: ^Device,
		textureDesc: ^TextureDesc,
		memoryLocation: MemoryLocation,
		memoryDesc: ^MemoryDesc,
	), // requires "features.getMemoryDesc2"
	CreateCommittedBuffer:        proc "c" (
		device: ^Device,
		memoryLocation: MemoryLocation,
		priority: f32,
		bufferDesc: ^BufferDesc,
		buffer: ^^Buffer,
	) -> Result,
	CreateCommittedTexture:       proc "c" (
		device: ^Device,
		memoryLocation: MemoryLocation,
		priority: f32,
		textureDesc: ^TextureDesc,
		texture: ^^Texture,
	) -> Result,
	CreatePlacedBuffer:           proc "c" (
		device: ^Device,
		memory: ^Memory,
		offset: u64,
		bufferDesc: ^BufferDesc,
		buffer: ^^Buffer,
	) -> Result,
	CreatePlacedTexture:          proc "c" (
		device: ^Device,
		memory: ^Memory,
		offset: u64,
		textureDesc: ^TextureDesc,
		texture: ^^Texture,
	) -> Result,

	// Descriptor set management (entities don't require destroying)
	// - if "ALLOW_UPDATE_AFTER_SET" not used, descriptor sets (and data pointed to by descriptors) must be updated before "CmdSetDescriptorSet"
	// - if "ALLOW_UPDATE_AFTER_SET" used, descriptor sets (and data pointed to by descriptors) can be updated after "CmdSetDescriptorSet"
	// - "ResetDescriptorPool" resets the pool and and wipes out all allocated descriptor sets
	AllocateDescriptorSets:       proc "c" (
		descriptorPool: ^DescriptorPool,
		pipelineLayout: ^PipelineLayout,
		setIndex: u32,
		descriptorSets: ^^DescriptorSet,
		instanceNum: u32,
		variableDescriptorNum: u32,
	) -> Result,
	UpdateDescriptorRanges:       proc "c" (
		updateDescriptorRangeDescs: ^UpdateDescriptorRangeDesc,
		updateDescriptorRangeDescNum: u32,
	),
	CopyDescriptorRanges:         proc "c" (
		copyDescriptorRangeDescs: ^CopyDescriptorRangeDesc,
		copyDescriptorRangeDescNum: u32,
	),
	ResetDescriptorPool:          proc "c" (descriptorPool: ^DescriptorPool),

	// Command buffer (one time submit)
	BeginCommandBuffer:           proc "c" (
		commandBuffer: ^CommandBuffer,
		descriptorPool: ^DescriptorPool,
	) -> Result,

	// {                {
	// Set descriptor pool (initially can be set via "BeginCommandBuffer")
	CmdSetDescriptorPool:         proc "c" (
		commandBuffer: ^CommandBuffer,
		descriptorPool: ^DescriptorPool,
	),

	// Resource binding (expect "CmdSetPipelineLayout" to be called first)
	CmdSetPipelineLayout:         proc "c" (
		commandBuffer: ^CommandBuffer,
		bindPoint: BindPoint,
		pipelineLayout: ^PipelineLayout,
	),
	CmdSetDescriptorSet:          proc "c" (
		commandBuffer: ^CommandBuffer,
		setDescriptorSetDesc: ^SetDescriptorSetDesc,
	),
	CmdSetRootConstants:          proc "c" (
		commandBuffer: ^CommandBuffer,
		setRootConstantsDesc: ^SetRootConstantsDesc,
	),
	CmdSetRootDescriptor:         proc "c" (
		commandBuffer: ^CommandBuffer,
		setRootDescriptorDesc: ^SetRootDescriptorDesc,
	),

	// Pipeline
	CmdSetPipeline:               proc "c" (commandBuffer: ^CommandBuffer, pipeline: ^Pipeline),

	// Barrier
	CmdBarrier:                   proc "c" (
		commandBuffer: ^CommandBuffer,
		barrierDesc: ^BarrierDesc,
	),

	// Input assembly
	CmdSetIndexBuffer:            proc "c" (
		commandBuffer: ^CommandBuffer,
		buffer: ^Buffer,
		offset: u64,
		indexType: IndexType,
	),
	CmdSetVertexBuffers:          proc "c" (
		commandBuffer: ^CommandBuffer,
		baseSlot: u32,
		vertexBufferDescs: ^VertexBufferDesc,
		vertexBufferNum: u32,
	),

	// Initial state
	CmdSetViewports:              proc "c" (
		commandBuffer: ^CommandBuffer,
		viewports: ^Viewport,
		viewportNum: u32,
	),
	CmdSetScissors:               proc "c" (
		commandBuffer: ^CommandBuffer,
		rects: ^Rect,
		rectNum: u32,
	),

	// Initial state, if enabled in any pipeline used in this command buffer
	CmdSetStencilReference:       proc "c" (
		commandBuffer: ^CommandBuffer,
		frontRef: u8,
		backRef: u8,
	), // "backRef" requires "features.independentFrontAndBackStencilReferenceAndMasks"
	CmdSetDepthBounds:            proc "c" (
		commandBuffer: ^CommandBuffer,
		boundsMin: f32,
		boundsMax: f32,
	), // requires "features.depthBoundsTest"
	CmdSetBlendConstants:         proc "c" (commandBuffer: ^CommandBuffer, color: ^Color32f),
	CmdSetSampleLocations:        proc "c" (
		commandBuffer: ^CommandBuffer,
		locations: ^SampleLocation,
		locationNum: Sample_t,
		sampleNum: Sample_t,
	), // requires "tiers.sampleLocations != 0"
	CmdSetShadingRate:            proc "c" (
		commandBuffer: ^CommandBuffer,
		shadingRateDesc: ^ShadingRateDesc,
	), // requires "tiers.shadingRate != 0"

	// State override
	CmdSetDepthBias:              proc "c" (
		commandBuffer: ^CommandBuffer,
		depthBiasDesc: ^DepthBiasDesc,
	), // requires "features.dynamicDepthBias"

	// Graphics
	CmdBeginRendering:            proc "c" (
		commandBuffer: ^CommandBuffer,
		attachmentsDesc: ^AttachmentsDesc,
	),

	// {                {
	// Fast clear
	CmdClearAttachments:          proc "c" (
		commandBuffer: ^CommandBuffer,
		clearDescs: ^ClearDesc,
		clearDescNum: u32,
		rects: ^Rect,
		rectNum: u32,
	),

	// Draw
	CmdDraw:                      proc "c" (commandBuffer: ^CommandBuffer, drawDesc: ^DrawDesc),
	CmdDrawIndexed:               proc "c" (
		commandBuffer: ^CommandBuffer,
		drawIndexedDesc: ^DrawIndexedDesc,
	),

	// Draw indirect:
	//  - drawNum = min(drawNum, countBuffer ? countBuffer[countBufferOffset] : INF)
	//  - see "Modified draw command signatures"
	CmdDrawIndirect:              proc "c" (
		commandBuffer: ^CommandBuffer,
		buffer: ^Buffer,
		offset: u64,
		drawNum: u32,
		stride: u32,
		countBuffer: ^Buffer,
		countBufferOffset: u64,
	), // "buffer" contains "Draw(Base)Desc" commands
	CmdDrawIndexedIndirect:       proc "c" (
		commandBuffer: ^CommandBuffer,
		buffer: ^Buffer,
		offset: u64,
		drawNum: u32,
		stride: u32,
		countBuffer: ^Buffer,
		countBufferOffset: u64,
	), // "buffer" contains "DrawIndexed(Base)Desc" commands

	// }                }
	CmdEndRendering:              proc "c" (commandBuffer: ^CommandBuffer),

	// Compute
	CmdDispatch:                  proc "c" (
		commandBuffer: ^CommandBuffer,
		dispatchDesc: ^DispatchDesc,
	),
	CmdDispatchIndirect:          proc "c" (
		commandBuffer: ^CommandBuffer,
		buffer: ^Buffer,
		offset: u64,
	), // buffer contains "DispatchDesc" commands

	// Copy
	CmdCopyBuffer:                proc "c" (
		commandBuffer: ^CommandBuffer,
		dstBuffer: ^Buffer,
		dstOffset: u64,
		srcBuffer: ^Buffer,
		srcOffset: u64,
		size: u64,
	),
	CmdCopyTexture:               proc "c" (
		commandBuffer: ^CommandBuffer,
		dstTexture: ^Texture,
		dstRegion: ^TextureRegionDesc,
		srcTexture: ^Texture,
		srcRegion: ^TextureRegionDesc,
	),
	CmdUploadBufferToTexture:     proc "c" (
		commandBuffer: ^CommandBuffer,
		dstTexture: ^Texture,
		dstRegion: ^TextureRegionDesc,
		srcBuffer: ^Buffer,
		srcDataLayout: ^TextureDataLayoutDesc,
	),
	CmdReadbackTextureToBuffer:   proc "c" (
		commandBuffer: ^CommandBuffer,
		dstBuffer: ^Buffer,
		dstDataLayout: ^TextureDataLayoutDesc,
		srcTexture: ^Texture,
		srcRegion: ^TextureRegionDesc,
	),
	CmdZeroBuffer:                proc "c" (
		commandBuffer: ^CommandBuffer,
		buffer: ^Buffer,
		offset: u64,
		size: u64,
	),

	// Resolve
	CmdResolveTexture:            proc "c" (
		commandBuffer: ^CommandBuffer,
		dstTexture: ^Texture,
		dstRegion: ^TextureRegionDesc,
		srcTexture: ^Texture,
		srcRegion: ^TextureRegionDesc,
	), // "features.regionResolve" is needed for region specification

	// Clear (potentially slow)
	CmdClearStorage:              proc "c" (
		commandBuffer: ^CommandBuffer,
		clearDesc: ^ClearStorageDesc,
	),

	// Query
	CmdResetQueries:              proc "c" (
		commandBuffer: ^CommandBuffer,
		queryPool: ^QueryPool,
		offset: u32,
		num: u32,
	),
	CmdBeginQuery:                proc "c" (
		commandBuffer: ^CommandBuffer,
		queryPool: ^QueryPool,
		offset: u32,
	),
	CmdEndQuery:                  proc "c" (
		commandBuffer: ^CommandBuffer,
		queryPool: ^QueryPool,
		offset: u32,
	),
	CmdCopyQueries:               proc "c" (
		commandBuffer: ^CommandBuffer,
		queryPool: ^QueryPool,
		offset: u32,
		num: u32,
		dstBuffer: ^Buffer,
		dstOffset: u64,
	),

	// Annotations for profiling tools: command buffer
	CmdBeginAnnotation:           proc "c" (
		commandBuffer: ^CommandBuffer,
		name: cstring,
		bgra: u32,
	),
	CmdEndAnnotation:             proc "c" (commandBuffer: ^CommandBuffer),
	CmdAnnotation:                proc "c" (
		commandBuffer: ^CommandBuffer,
		name: cstring,
		bgra: u32,
	),

	// }                }
	EndCommandBuffer:             proc "c" (commandBuffer: ^CommandBuffer) -> Result, // D3D11 performs state tracking and resets it there

	// Annotations for profiling tools: command queue - D3D11: NOP
	QueueBeginAnnotation:         proc "c" (queue: ^Queue, name: cstring, bgra: u32),
	QueueEndAnnotation:           proc "c" (queue: ^Queue),
	QueueAnnotation:              proc "c" (queue: ^Queue, name: cstring, bgra: u32),

	// Query
	ResetQueries:                 proc "c" (queryPool: ^QueryPool, offset: u32, num: u32), // on host

	// Work submission and synchronization
	QueueSubmit:                  proc "c" (
		queue: ^Queue,
		queueSubmitDesc: ^QueueSubmitDesc,
	) -> Result, // to device
	QueueWaitIdle:                proc "c" (queue: ^Queue) -> Result,
	DeviceWaitIdle:               proc "c" (device: ^Device) -> Result,
	Wait:                         proc "c" (fence: ^Fence, value: u64), // on host

	// Command allocator
	ResetCommandAllocator:        proc "c" (commandAllocator: ^CommandAllocator),

	// Map / Unmap
	// D3D11: no persistent mapping
	// D3D12: persistent mapping, "Map/Unmap" do nothing
	// VK: persistent mapping, but "Unmap" can do a flush if underlying memory is not "HOST_COHERENT" (unlikely)
	MapBuffer:                    proc "c" (buffer: ^Buffer, offset: u64, size: u64) -> rawptr,
	UnmapBuffer:                  proc "c" (buffer: ^Buffer),

	// Debug name for any object declared as "NriForwardStruct" (skipped for buffers & textures in D3D if they are not bound to a memory)
	SetDebugName:                 proc "c" (object: ^Object, name: cstring),

	// Native objects                                                                                            ___D3D11 (latest interface)________|_D3D12 (latest interface)____|_VK_________________________________
	GetDeviceNativeObject:        proc "c" (device: ^Device) -> rawptr, // ID3D11Device*                   | ID3D12Device*               | VkDevice
	GetQueueNativeObject:         proc "c" (queue: ^Queue) -> rawptr, // -                               | ID3D12CommandQueue*         | VkQueue
	GetCommandBufferNativeObject: proc "c" (commandBuffer: ^CommandBuffer) -> rawptr, // ID3D11DeviceContext*            | ID3D12GraphicsCommandList*  | VkCommandBuffer
	GetBufferNativeObject:        proc "c" (buffer: ^Buffer) -> u64, // ID3D11Buffer*                   | ID3D12Resource*             | VkBuffer
	GetTextureNativeObject:       proc "c" (texture: ^Texture) -> u64, // ID3D11Resource*                 | ID3D12Resource*             | VkImage
	GetDescriptorNativeObject:    proc "c" (descriptor: ^Descriptor) -> u64, // ID3D11View/ID3D11SamplerState*  | D3D12_CPU_DESCRIPTOR_HANDLE | VkImageView/VkBufferView/VkSampler
}
