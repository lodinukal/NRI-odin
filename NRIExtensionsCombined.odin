package NRI

import "core:c"

import "vendor:directx/dxgi"

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

Message :: enum u8 {
	INFO    = 0,
	WARNING = 1,
	ERROR   = 2,
	MAX_NUM = 3,
}

AllocationCallbacks :: struct {
	Allocate:                           proc "c" (
		userArg: rawptr,
		size: c.size_t,
		alignment: c.size_t,
	) -> rawptr,
	Reallocate:                         proc "c" (
		userArg: rawptr,
		memory: rawptr,
		size: c.size_t,
		alignment: c.size_t,
	) -> rawptr,
	Free:                               proc "c" (userArg: rawptr, memory: rawptr),
	userArg:                            rawptr,
	disable3rdPartyAllocationCallbacks: bool,
}

CallbackInterface :: struct {
	MessageCallback: proc "c" (
		messageType: Message,
		file: cstring,
		line: u32,
		message: cstring,
		userArg: rawptr,
	),
	AbortExecution:  proc "c" (userArg: rawptr),
	userArg:         rawptr,
}

VKBindingOffsets :: struct {
	samplerOffset:                 u32,
	textureOffset:                 u32,
	constantBufferOffset:          u32,
	storageTextureAndBufferOffset: u32,
}

VKExtensions :: struct {
	instanceExtensions:   ^cstring,
	instanceExtensionNum: u32,
	deviceExtensions:     ^cstring,
	deviceExtensionNum:   u32,
}

QueueFamilyDesc :: struct {
	queuePriorities: ^f32,
	queueNum:        u32,
	queueType:       QueueType,
}

DeviceCreationDesc :: struct {
	graphicsAPI:                       GraphicsAPI,
	robustness:                        Robustness,
	adapterDesc:                       ^AdapterDesc,
	callbackInterface:                 CallbackInterface,
	allocationCallbacks:               AllocationCallbacks,
	queueFamilies:                     ^QueueFamilyDesc,
	queueFamilyNum:                    u32,
	d3dShaderExtRegister:              u32,
	d3dZeroBufferSize:                 u32,
	vkBindingOffsets:                  VKBindingOffsets,
	vkExtensions:                      VKExtensions,
	enableNRIValidation:               bool,
	enableGraphicsAPIValidation:       bool,
	enableD3D11CommandBufferEmulation: bool,
	enableD3D12RayTracingValidation:   bool,
	enableMemoryZeroInitialization:    bool,
	disableVKRayTracing:               bool,
	disableD3D12EnhancedBarriers:      bool,
}

@(default_calling_convention = "c", link_prefix = "nri")
foreign lib {
	EnumerateAdapters :: proc(adapterDescs: ^AdapterDesc, adapterDescNum: ^u32) -> Result ---
	CreateDevice :: proc(deviceCreationDesc: ^DeviceCreationDesc, device: ^^Device) -> Result ---
	DestroyDevice :: proc(device: ^Device) ---
	ReportLiveObjects :: proc() ---
}

VideoMemoryInfo :: struct {
	budgetSize: u64,
	usageSize:  u64,
}

TextureSubresourceUploadDesc :: struct {
	slices:     rawptr,
	sliceNum:   u32,
	rowPitch:   u32,
	slicePitch: u32,
}

TextureUploadDesc :: struct {
	subresources: ^TextureSubresourceUploadDesc,
	texture:      ^Texture,
	after:        AccessLayoutStage,
	planes:       PlaneBits,
}

BufferUploadDesc :: struct {
	data:   rawptr,
	buffer: ^Buffer,
	after:  AccessStage,
}

ResourceGroupDesc :: struct {
	memoryLocation:      MemoryLocation,
	textures:            ^^Texture,
	textureNum:          u32,
	buffers:             ^^Buffer,
	bufferNum:           u32,
	preferredMemorySize: u64,
}

// FormatProps :: struct {
// 	name:         cstring,
// 	format:       Format,
// 	redBits:      u8,
// 	greenBits:    u8,
// 	blueBits:     u8,
// 	alphaBits:    u8,
// 	stride:       u32,
// 	blockWidth:   u32,
// 	blockHeight:  u32,
// 	isBgr:        u32,
// 	isCompressed: u32,
// 	isDepth:      u32,
// 	isExpShared:  u32,
// 	isFloat:      u32,
// 	isPacked:     u32,
// 	isInteger:    u32,
// 	isNorm:       u32,
// 	isSigned:     u32,
// 	isSrgb:       u32,
// 	isStencil:    u32,
// 	unused:       u32,
// }

HelperInterface :: struct {
	CalculateAllocationNumber: proc "c" (
		device: ^Device,
		resourceGroupDesc: ^ResourceGroupDesc,
	) -> u32,
	AllocateAndBindMemory:     proc "c" (
		device: ^Device,
		resourceGroupDesc: ^ResourceGroupDesc,
		allocations: ^^Memory,
	) -> Result,
	UploadData:                proc "c" (
		queue: ^Queue,
		textureUploadDescs: ^TextureUploadDesc,
		textureUploadDescNum: u32,
		bufferUploadDescs: ^BufferUploadDesc,
		bufferUploadDescNum: u32,
	) -> Result,
	QueryVideoMemoryInfo:      proc "c" (
		device: ^Device,
		memoryLocation: MemoryLocation,
		videoMemoryInfo: ^VideoMemoryInfo,
	) -> Result,
}

@(default_calling_convention = "c", link_prefix = "nri")
foreign lib {
	ConvertDXGIFormatToNRI :: proc(dxgiFormat: u32) -> Format ---
	ConvertVKFormatToNRI :: proc(vkFormat: u32) -> Format ---
	ConvertNRIFormatToDXGI :: proc(format: Format) -> u32 ---
	ConvertNRIFormatToVK :: proc(format: Format) -> u32 ---
	// TODO: make use proper bit field
	// GetFormatProps :: proc(format: Format) -> ^FormatProps ---
	GetGraphicsAPIString :: proc(graphicsAPI: GraphicsAPI) -> cstring ---
}

PipelineLayoutSettingsDesc :: struct {
	descriptorSetNum:                   u32,
	descriptorRangeNum:                 u32,
	rootConstantSize:                   u32,
	rootDescriptorNum:                  u32,
	preferRootDescriptorsOverConstants: bool,
	enableD3D12DrawParametersEmulation: bool,
}

ImDrawList :: struct {}
ImTextureData :: struct {}
Imgui :: struct {}
Streamer :: struct {}

ImguiDesc :: struct {
	descriptorPoolSize: u32,
}

CopyImguiDataDesc :: struct {
	drawLists:   ^^ImDrawList,
	drawListNum: u32,
	textures:    ^^ImTextureData,
	textureNum:  u32,
}

DrawImguiDesc :: struct {
	drawLists:        ^^ImDrawList,
	drawListNum:      u32,
	displaySize:      Dim2_t,
	hdrScale:         f32,
	attachmentFormat: Format,
	linearColor:      bool,
}

ImguiInterface :: struct {
	CreateImgui:      proc "c" (device: ^Device, imguiDesc: ^ImguiDesc, imgui: ^^Imgui) -> Result,
	DestroyImgui:     proc "c" (imgui: ^Imgui),
	CmdCopyImguiData: proc "c" (
		commandBuffer: ^CommandBuffer,
		streamer: ^Streamer,
		imgui: ^Imgui,
		streamImguiDesc: ^CopyImguiDataDesc,
	),
	CmdDrawImgui:     proc "c" (
		commandBuffer: ^CommandBuffer,
		imgui: ^Imgui,
		drawImguiDesc: ^DrawImguiDesc,
	),
}

LatencyMarker :: enum u8 {
	SIMULATION_START    = 0,
	SIMULATION_END      = 1,
	RENDER_SUBMIT_START = 2,
	RENDER_SUBMIT_END   = 3,
	INPUT_SAMPLE        = 6,
	MAX_NUM             = 7,
}

LatencySleepMode :: struct {
	minIntervalUs:   u32,
	lowLatencyMode:  bool,
	lowLatencyBoost: bool,
}

LatencyReport :: struct {
	inputSampleTimeUs:        u64,
	simulationStartTimeUs:    u64,
	simulationEndTimeUs:      u64,
	renderSubmitStartTimeUs:  u64,
	renderSubmitEndTimeUs:    u64,
	presentStartTimeUs:       u64,
	presentEndTimeUs:         u64,
	driverStartTimeUs:        u64,
	driverEndTimeUs:          u64,
	osRenderQueueStartTimeUs: u64,
	osRenderQueueEndTimeUs:   u64,
	gpuRenderStartTimeUs:     u64,
	gpuRenderEndTimeUs:       u64,
}

LowLatencyInterface :: struct {
	SetLatencySleepMode: proc "c" (
		swapChain: ^SwapChain,
		latencySleepMode: ^LatencySleepMode,
	) -> Result,
	SetLatencyMarker:    proc "c" (swapChain: ^SwapChain, latencyMarker: LatencyMarker) -> Result,
	LatencySleep:        proc "c" (swapChain: ^SwapChain) -> Result,
	GetLatencyReport:    proc "c" (swapChain: ^SwapChain, latencyReport: ^LatencyReport) -> Result,
}

DrawMeshTasksDesc :: struct {
	x, y, z: u32,
}

MeshShaderInterface :: struct {
	CmdDrawMeshTasks:         proc "c" (
		commandBuffer: ^CommandBuffer,
		drawMeshTasksDesc: ^DrawMeshTasksDesc,
	),
	CmdDrawMeshTasksIndirect: proc "c" (
		commandBuffer: ^CommandBuffer,
		buffer: ^Buffer,
		offset: u64,
		drawNum: u32,
		stride: u32,
		countBuffer: ^Buffer,
		countBufferOffset: u64,
	),
}

AccelerationStructure :: struct {}
Micromap :: struct {}

RayTracingPipelineBits :: enum i32 {
	NONE            = 0,
	SKIP_TRIANGLES  = 1,
	SKIP_AABBS      = 2,
	ALLOW_MICROMAPS = 4,
}

ShaderLibraryDesc :: struct {
	shaders:   ^ShaderDesc,
	shaderNum: u32,
}

ShaderGroupDesc :: struct {
	shaderIndices: [3]u32,
}

RayTracingPipelineDesc :: struct {
	pipelineLayout:         ^PipelineLayout,
	shaderLibrary:          ^ShaderLibraryDesc,
	shaderGroups:           ^ShaderGroupDesc,
	shaderGroupNum:         u32,
	recursionMaxDepth:      u32,
	rayPayloadMaxSize:      u32,
	rayHitAttributeMaxSize: u32,
	flags:                  RayTracingPipelineBits,
	robustness:             Robustness,
}

MicromapFormat :: enum i32 {
	OPACITY_2_STATE = 1,
	OPACITY_4_STATE = 2,
	MAX_NUM         = 3,
}

MicromapSpecialIndex :: enum i32 {
	FULLY_TRANSPARENT         = -1,
	FULLY_OPAQUE              = -2,
	FULLY_UNKNOWN_TRANSPARENT = -3,
	FULLY_UNKNOWN_OPAQUE      = -4,
	MAX_NUM                   = -3,
}

MicromapBits :: enum i32 {
	NONE              = 0,
	ALLOW_COMPACTION  = 2,
	PREFER_FAST_TRACE = 4,
	PREFER_FAST_BUILD = 8,
}

MicromapUsageDesc :: struct {
	triangleNum:      u32,
	subdivisionLevel: u16,
	format:           MicromapFormat,
}

MicromapDesc :: struct {
	optimizedSize: u64,
	usages:        ^MicromapUsageDesc,
	usageNum:      u32,
	flags:         MicromapBits,
}

BindMicromapMemoryDesc :: struct {
	micromap: ^Micromap,
	memory:   ^Memory,
	offset:   u64,
}

BuildMicromapDesc :: struct {
	dst:            ^Micromap,
	dataBuffer:     ^Buffer,
	dataOffset:     u64,
	triangleBuffer: ^Buffer,
	triangleOffset: u64,
	scratchBuffer:  ^Buffer,
	scratchOffset:  u64,
}

BottomLevelMicromapDesc :: struct {
	micromap:     ^Micromap,
	indexBuffer:  ^Buffer,
	indexOffset:  u64,
	baseTriangle: u32,
	indexType:    IndexType,
}

MicromapTriangle :: struct {
	dataOffset:       u32,
	subdivisionLevel: u16,
	format:           MicromapFormat,
}

BottomLevelGeometryType :: enum i32 {
	TRIANGLES = 0,
	AABBS     = 1,
	MAX_NUM   = 2,
}

BottomLevelGeometryBits :: enum i32 {
	NONE                            = 0,
	OPAQUE_GEOMETRY                 = 1,
	NO_DUPLICATE_ANY_HIT_INVOCATION = 2,
}

BottomLevelTrianglesDesc :: struct {
	vertexBuffer:    ^Buffer,
	vertexOffset:    u64,
	vertexNum:       u32,
	vertexStride:    u16,
	vertexFormat:    Format,
	indexBuffer:     ^Buffer,
	indexOffset:     u64,
	indexNum:        u32,
	indexType:       IndexType,
	transformBuffer: ^Buffer,
	transformOffset: u64,
	micromap:        ^BottomLevelMicromapDesc,
}

BottomLevelAabbsDesc :: struct {
	buffer: ^Buffer,
	offset: u64,
	num:    u32,
	stride: u32,
}

BottomLevelGeometryDesc :: struct {
	flags:   BottomLevelGeometryBits,
	type:    BottomLevelGeometryType,
	using _: struct #raw_union {
		triangles: BottomLevelTrianglesDesc,
		aabbs:     BottomLevelAabbsDesc,
	},
}

TransformMatrix :: struct {
	transform: [3][4]f32,
}

BottomLevelAabb :: struct {
	minX: f32,
	minY: f32,
	minZ: f32,
	maxX: f32,
	maxY: f32,
	maxZ: f32,
}

TopLevelInstanceBits :: enum i32 {
	NONE                  = 0,
	TRIANGLE_CULL_DISABLE = 1,
	TRIANGLE_FLIP_FACING  = 2,
	FORCE_OPAQUE          = 4,
	FORCE_NON_OPAQUE      = 8,
	FORCE_OPACITY_2_STATE = 16,
	DISABLE_MICROMAPS     = 32,
}

TopLevelInstance :: struct {
	transform:                     [3][4]f32,
	instanceId:                    u32,
	mask:                          u32,
	shaderBindingTableLocalOffset: u32,
	flags:                         TopLevelInstanceBits,
	accelerationStructureHandle:   u64,
}

AccelerationStructureType :: enum i32 {
	TOP_LEVEL    = 0,
	BOTTOM_LEVEL = 1,
	MAX_NUM      = 2,
}

AccelerationStructureBits :: enum i32 {
	NONE                    = 0,
	ALLOW_UPDATE            = 1,
	ALLOW_COMPACTION        = 2,
	ALLOW_DATA_ACCESS       = 4,
	ALLOW_MICROMAP_UPDATE   = 8,
	ALLOW_DISABLE_MICROMAPS = 16,
	PREFER_FAST_TRACE       = 32,
	PREFER_FAST_BUILD       = 64,
	MINIMIZE_MEMORY         = 128,
}

AccelerationStructureDesc :: struct {
	optimizedSize:         u64,
	geometries:            ^BottomLevelGeometryDesc,
	geometryOrInstanceNum: u32,
	flags:                 AccelerationStructureBits,
	type:                  AccelerationStructureType,
}

BindAccelerationStructureMemoryDesc :: struct {
	accelerationStructure: ^AccelerationStructure,
	memory:                ^Memory,
	offset:                u64,
}

BuildTopLevelAccelerationStructureDesc :: struct {
	dst:            ^AccelerationStructure,
	src:            ^AccelerationStructure,
	instanceNum:    u32,
	instanceBuffer: ^Buffer,
	instanceOffset: u64,
	scratchBuffer:  ^Buffer,
	scratchOffset:  u64,
}

BuildBottomLevelAccelerationStructureDesc :: struct {
	dst:           ^AccelerationStructure,
	src:           ^AccelerationStructure,
	geometries:    ^BottomLevelGeometryDesc,
	geometryNum:   u32,
	scratchBuffer: ^Buffer,
	scratchOffset: u64,
}

CopyMode :: enum i32 {
	CLONE   = 0,
	COMPACT = 1,
	MAX_NUM = 2,
}

StridedBufferRegion :: struct {
	buffer: ^Buffer,
	offset: u64,
	size:   u64,
	stride: u64,
}

DispatchRaysDesc :: struct {
	raygenShader:    StridedBufferRegion,
	missShaders:     StridedBufferRegion,
	hitShaderGroups: StridedBufferRegion,
	callableShaders: StridedBufferRegion,
	x, y, z:         u32,
}

DispatchRaysIndirectDesc :: struct {
	raygenShaderRecordAddress:         u64,
	raygenShaderRecordSize:            u64,
	missShaderBindingTableAddress:     u64,
	missShaderBindingTableSize:        u64,
	missShaderBindingTableStride:      u64,
	hitShaderBindingTableAddress:      u64,
	hitShaderBindingTableSize:         u64,
	hitShaderBindingTableStride:       u64,
	callableShaderBindingTableAddress: u64,
	callableShaderBindingTableSize:    u64,
	callableShaderBindingTableStride:  u64,
	x, y, z:                           u32,
}

RayTracingInterface :: struct {
	CreateRayTracingPipeline:                        proc "c" (
		device: ^Device,
		rayTracingPipelineDesc: ^RayTracingPipelineDesc,
		pipeline: ^^Pipeline,
	) -> Result,
	CreateAccelerationStructureDescriptor:           proc "c" (
		accelerationStructure: ^AccelerationStructure,
		descriptor: ^^Descriptor,
	) -> Result,
	GetAccelerationStructureHandle:                  proc "c" (
		accelerationStructure: ^AccelerationStructure,
	) -> u64,
	GetAccelerationStructureUpdateScratchBufferSize: proc "c" (
		accelerationStructure: ^AccelerationStructure,
	) -> u64,
	GetAccelerationStructureBuildScratchBufferSize:  proc "c" (
		accelerationStructure: ^AccelerationStructure,
	) -> u64,
	GetMicromapBuildScratchBufferSize:               proc "c" (micromap: ^Micromap) -> u64,
	GetAccelerationStructureBuffer:                  proc "c" (
		accelerationStructure: ^AccelerationStructure,
	) -> ^Buffer,
	GetMicromapBuffer:                               proc "c" (micromap: ^Micromap) -> ^Buffer,
	DestroyAccelerationStructure:                    proc "c" (
		accelerationStructure: ^AccelerationStructure,
	),
	DestroyMicromap:                                 proc "c" (micromap: ^Micromap),
	CreateAccelerationStructure:                     proc "c" (
		device: ^Device,
		accelerationStructureDesc: ^AccelerationStructureDesc,
		accelerationStructure: ^^AccelerationStructure,
	) -> Result,
	CreateMicromap:                                  proc "c" (
		device: ^Device,
		micromapDesc: ^MicromapDesc,
		micromap: ^^Micromap,
	) -> Result,
	GetAccelerationStructureMemoryDesc:              proc "c" (
		accelerationStructure: ^AccelerationStructure,
		memoryLocation: MemoryLocation,
		memoryDesc: ^MemoryDesc,
	),
	GetMicromapMemoryDesc:                           proc "c" (
		micromap: ^Micromap,
		memoryLocation: MemoryLocation,
		memoryDesc: ^MemoryDesc,
	),
	BindAccelerationStructureMemory:                 proc "c" (
		bindAccelerationStructureMemoryDescs: ^BindAccelerationStructureMemoryDesc,
		bindAccelerationStructureMemoryDescNum: u32,
	) -> Result,
	BindMicromapMemory:                              proc "c" (
		bindMicromapMemoryDescs: ^BindMicromapMemoryDesc,
		bindMicromapMemoryDescNum: u32,
	) -> Result,
	GetAccelerationStructureMemoryDesc2:             proc "c" (
		device: ^Device,
		accelerationStructureDesc: ^AccelerationStructureDesc,
		memoryLocation: MemoryLocation,
		memoryDesc: ^MemoryDesc,
	),
	GetMicromapMemoryDesc2:                          proc "c" (
		device: ^Device,
		micromapDesc: ^MicromapDesc,
		memoryLocation: MemoryLocation,
		memoryDesc: ^MemoryDesc,
	),
	CreateCommittedAccelerationStructure:            proc "c" (
		device: ^Device,
		memoryLocation: MemoryLocation,
		priority: f32,
		accelerationStructureDesc: ^AccelerationStructureDesc,
		accelerationStructure: ^^AccelerationStructure,
	) -> Result,
	CreateCommittedMicromap:                         proc "c" (
		device: ^Device,
		memoryLocation: MemoryLocation,
		priority: f32,
		micromapDesc: ^MicromapDesc,
		micromap: ^^Micromap,
	) -> Result,
	CreatePlacedAccelerationStructure:               proc "c" (
		device: ^Device,
		memory: ^Memory,
		offset: u64,
		accelerationStructureDesc: ^AccelerationStructureDesc,
		accelerationStructure: ^^AccelerationStructure,
	) -> Result,
	CreatePlacedMicromap:                            proc "c" (
		device: ^Device,
		memory: ^Memory,
		offset: u64,
		micromapDesc: ^MicromapDesc,
		micromap: ^^Micromap,
	) -> Result,
	WriteShaderGroupIdentifiers:                     proc "c" (
		pipeline: ^Pipeline,
		baseShaderGroupIndex: u32,
		shaderGroupNum: u32,
		dst: rawptr,
	) -> Result,
	CmdBuildMicromaps:                               proc "c" (
		commandBuffer: ^CommandBuffer,
		buildMicromapDescs: ^BuildMicromapDesc,
		buildMicromapDescNum: u32,
	),
	CmdWriteMicromapsSizes:                          proc "c" (
		commandBuffer: ^CommandBuffer,
		micromaps: ^^Micromap,
		micromapNum: u32,
		queryPool: ^QueryPool,
		queryPoolOffset: u32,
	),
	CmdCopyMicromap:                                 proc "c" (
		commandBuffer: ^CommandBuffer,
		dst: ^Micromap,
		src: ^Micromap,
		copyMode: CopyMode,
	),
	CmdBuildTopLevelAccelerationStructures:          proc "c" (
		commandBuffer: ^CommandBuffer,
		buildTopLevelAccelerationStructureDescs: ^BuildTopLevelAccelerationStructureDesc,
		buildTopLevelAccelerationStructureDescNum: u32,
	),
	CmdBuildBottomLevelAccelerationStructures:       proc "c" (
		commandBuffer: ^CommandBuffer,
		buildBotomLevelAccelerationStructureDescs: ^BuildBottomLevelAccelerationStructureDesc,
		buildBotomLevelAccelerationStructureDescNum: u32,
	),
	CmdWriteAccelerationStructuresSizes:             proc "c" (
		commandBuffer: ^CommandBuffer,
		accelerationStructures: ^^AccelerationStructure,
		accelerationStructureNum: u32,
		queryPool: ^QueryPool,
		queryPoolOffset: u32,
	),
	CmdCopyAccelerationStructure:                    proc "c" (
		commandBuffer: ^CommandBuffer,
		dst: ^AccelerationStructure,
		src: ^AccelerationStructure,
		copyMode: CopyMode,
	),
	CmdDispatchRays:                                 proc "c" (
		commandBuffer: ^CommandBuffer,
		dispatchRaysDesc: ^DispatchRaysDesc,
	),
	CmdDispatchRaysIndirect:                         proc "c" (
		commandBuffer: ^CommandBuffer,
		buffer: ^Buffer,
		offset: u64,
	),
	GetAccelerationStructureNativeObject:            proc "c" (
		accelerationStructure: ^AccelerationStructure,
	) -> u64,
	GetMicromapNativeObject:                         proc "c" (micromap: ^Micromap) -> u64,
}

DataSize :: struct {
	data: rawptr,
	size: u64,
}

BufferOffset :: struct {
	buffer: ^Buffer,
	offset: u64,
}

StreamerDesc :: struct {
	constantBufferMemoryLocation: MemoryLocation,
	constantBufferSize:           u64,
	dynamicBufferMemoryLocation:  MemoryLocation,
	dynamicBufferDesc:            BufferDesc,
	queuedFrameNum:               u32,
}

StreamBufferDataDesc :: struct {
	dataChunks:         ^DataSize,
	dataChunkNum:       u32,
	placementAlignment: u32,
	dstBuffer:          ^Buffer,
	dstOffset:          u64,
}

StreamTextureDataDesc :: struct {
	data:           rawptr,
	dataRowPitch:   u32,
	dataSlicePitch: u32,
	dstTexture:     ^Texture,
	dstRegion:      TextureRegionDesc,
}

StreamerInterface :: struct {
	CreateStreamer:            proc "c" (
		device: ^Device,
		streamerDesc: ^StreamerDesc,
		streamer: ^^Streamer,
	) -> Result,
	DestroyStreamer:           proc "c" (streamer: ^Streamer),
	GetStreamerConstantBuffer: proc "c" (streamer: ^Streamer) -> ^Buffer,
	StreamBufferData:          proc "c" (
		streamer: ^Streamer,
		streamBufferDataDesc: ^StreamBufferDataDesc,
	) -> BufferOffset,
	StreamTextureData:         proc "c" (
		streamer: ^Streamer,
		streamTextureDataDesc: ^StreamTextureDataDesc,
	) -> BufferOffset,
	StreamConstantData:        proc "c" (streamer: ^Streamer, data: rawptr, dataSize: u32) -> u32,
	CmdCopyStreamedData:       proc "c" (commandBuffer: ^CommandBuffer, streamer: ^Streamer),
	EndStreamerFrame:          proc "c" (streamer: ^Streamer),
}

SwapChainFormat :: enum u8 {
	BT709_G10_16BIT    = 0,
	BT709_G22_8BIT     = 1,
	BT709_G22_10BIT    = 2,
	BT2020_G2084_10BIT = 3,
	MAX_NUM            = 4,
}

Scaling :: enum u8 {
	ONE_TO_ONE = 0,
	STRETCH    = 1,
	MAX_NUM    = 2,
}

Gravity :: enum u8 {
	MIN      = 0,
	MAX      = 1,
	CENTERED = 2,
	MAX_NUM  = 3,
}

SwapChainBitsEnum :: enum i32 {
	VSYNC             = 0,
	WAITABLE          = 1,
	ALLOW_TEARING     = 2,
	ALLOW_LOW_LATENCY = 3,
}

SwapChainBits :: bit_set[SwapChainBitsEnum;u8]

WindowsWindow :: struct {
	hwnd: rawptr,
}

X11Window :: struct {
	dpy:    rawptr,
	window: u64,
}

WaylandWindow :: struct {
	display: rawptr,
	surface: rawptr,
}

MetalWindow :: struct {
	caMetalLayer: rawptr,
}

Window :: struct {
	windows: WindowsWindow,
	x11:     X11Window,
	wayland: WaylandWindow,
	metal:   MetalWindow,
}

SwapChainDesc :: struct {
	window:         Window,
	queue:          ^Queue,
	width:          Dim_t,
	height:         Dim_t,
	textureNum:     u8,
	format:         SwapChainFormat,
	flags:          SwapChainBits,
	queuedFrameNum: u8,
	scaling:        Scaling,
	gravityX:       Gravity,
	gravityY:       Gravity,
}

ChromaticityCoords :: struct {
	x, y: f32,
}

DisplayDesc :: struct {
	redPrimary:            ChromaticityCoords,
	greenPrimary:          ChromaticityCoords,
	bluePrimary:           ChromaticityCoords,
	whitePoint:            ChromaticityCoords,
	minLuminance:          f32,
	maxLuminance:          f32,
	maxFullFrameLuminance: f32,
	sdrLuminance:          f32,
	isHDR:                 bool,
}

SwapChainInterface :: struct {
	CreateSwapChain:      proc "c" (
		device: ^Device,
		swapChainDesc: ^SwapChainDesc,
		swapChain: ^^SwapChain,
	) -> Result,
	DestroySwapChain:     proc "c" (swapChain: ^SwapChain),
	GetSwapChainTextures: proc "c" (swapChain: ^SwapChain, textureNum: ^u32) -> [^]^Texture,
	GetDisplayDesc:       proc "c" (swapChain: ^SwapChain, displayDesc: ^DisplayDesc) -> Result,
	AcquireNextTexture:   proc "c" (
		swapChain: ^SwapChain,
		acquireSemaphore: ^Fence,
		textureIndex: ^u32,
	) -> Result,
	WaitForPresent:       proc "c" (swapChain: ^SwapChain) -> Result,
	QueuePresent:         proc "c" (swapChain: ^SwapChain, releaseSemaphore: ^Fence) -> Result,
}

Upscaler :: struct {}

UpscalerType :: enum i32 {
	NIS     = 0,
	FSR     = 1,
	XESS    = 2,
	DLSR    = 3,
	DLRR    = 4,
	MAX_NUM = 5,
}

UpscalerMode :: enum i32 {
	NATIVE            = 0,
	ULTRA_QUALITY     = 1,
	QUALITY           = 2,
	BALANCED          = 3,
	PERFORMANCE       = 4,
	ULTRA_PERFORMANCE = 5,
	MAX_NUM           = 6,
}

UpscalerBits :: enum i32 {
	NONE           = 0,
	HDR            = 1,
	SRGB           = 2,
	USE_EXPOSURE   = 4,
	USE_REACTIVE   = 8,
	DEPTH_INVERTED = 16,
	DEPTH_INFINITE = 32,
	DEPTH_LINEAR   = 64,
	MV_UPSCALED    = 128,
	MV_JITTERED    = 256,
}

DispatchUpscaleBits :: enum i32 {
	NONE                = 0,
	RESET_HISTORY       = 1,
	USE_SPECULAR_MOTION = 2,
}

UpscalerDesc :: struct {
	upscaleResolution: Dim2_t,
	type:              UpscalerType,
	mode:              UpscalerMode,
	flags:             UpscalerBits,
	preset:            u8,
	commandBuffer:     ^CommandBuffer,
}

UpscalerProps :: struct {
	scalingFactor:       f32,
	mipBias:             f32,
	upscaleResolution:   Dim2_t,
	renderResolution:    Dim2_t,
	renderResolutionMin: Dim2_t,
	jitterPhaseNum:      u8,
}

UpscalerResource :: struct {
	texture:    ^Texture,
	descriptor: ^Descriptor,
}

UpscalerGuides :: struct {
	mv:       UpscalerResource,
	depth:    UpscalerResource,
	exposure: UpscalerResource,
	reactive: UpscalerResource,
}

DenoiserGuides :: struct {
	mv:               UpscalerResource,
	depth:            UpscalerResource,
	normalRoughness:  UpscalerResource,
	diffuseAlbedo:    UpscalerResource,
	specularAlbedo:   UpscalerResource,
	specularMvOrHitT: UpscalerResource,
	exposure:         UpscalerResource,
	reactive:         UpscalerResource,
	sss:              UpscalerResource,
}

NISSettings :: struct {
	sharpness: f32,
}

FSRSettings :: struct {
	zNear:                   f32,
	zFar:                    f32,
	verticalFov:             f32,
	frameTime:               f32,
	viewSpaceToMetersFactor: f32,
	sharpness:               f32,
}

DLRRSettings :: struct {
	worldToViewMatrix: [16]f32,
	viewToClipMatrix:  [16]f32,
}

DispatchUpscaleDesc :: struct {
	output:            UpscalerResource,
	input:             UpscalerResource,
	guides:            struct #raw_union {
		upscaler: UpscalerGuides,
		denoiser: DenoiserGuides,
	},
	settings:          struct #raw_union {
		nis:  NISSettings,
		fsr:  FSRSettings,
		dlrr: DLRRSettings,
	},
	currentResolution: Dim2_t,
	cameraJitter:      Float2_t,
	mvScale:           Float2_t,
	flags:             DispatchUpscaleBits,
}

UpscalerInterface :: struct {
	CreateUpscaler:      proc "c" (
		device: ^Device,
		upscalerDesc: ^UpscalerDesc,
		upscaler: ^^Upscaler,
	) -> Result,
	DestroyUpscaler:     proc "c" (upscaler: ^Upscaler),
	IsUpscalerSupported: proc "c" (device: ^Device, type: UpscalerType) -> bool,
	GetUpscalerProps:    proc "c" (upscaler: ^Upscaler, upscalerProps: ^UpscalerProps),
	CmdDispatchUpscale:  proc "c" (
		commandBuffer: ^CommandBuffer,
		upscaler: ^Upscaler,
		dispatchUpscaleDesc: ^DispatchUpscaleDesc,
	),
}

AGSContext :: struct {}
ID3D11Device :: struct {}
ID3D11Resource :: struct {}
ID3D11DeviceContext :: struct {}

DeviceCreationD3D11Desc :: struct {
	d3d11Device:                       ^ID3D11Device,
	agsContext:                        ^AGSContext,
	callbackInterface:                 CallbackInterface,
	allocationCallbacks:               AllocationCallbacks,
	d3dShaderExtRegister:              u32,
	d3dZeroBufferSize:                 u32,
	enableNRIValidation:               bool,
	enableD3D11CommandBufferEmulation: bool,
	disableNVAPIInitialization:        bool,
}

CommandBufferD3D11Desc :: struct {
	d3d11DeviceContext: ^ID3D11DeviceContext,
}

BufferD3D11Desc :: struct {
	d3d11Resource: ^ID3D11Resource,
	desc:          ^BufferDesc,
}

TextureD3D11Desc :: struct {
	d3d11Resource: ^ID3D11Resource,
	format:        dxgi.FORMAT,
}

WrapperD3D11Interface :: struct {
	CreateCommandBufferD3D11: proc "c" (
		device: ^Device,
		commandBufferD3D11Desc: ^CommandBufferD3D11Desc,
		commandBuffer: ^^CommandBuffer,
	) -> Result,
	CreateBufferD3D11:        proc "c" (
		device: ^Device,
		bufferD3D11Desc: ^BufferD3D11Desc,
		buffer: ^^Buffer,
	) -> Result,
	CreateTextureD3D11:       proc "c" (
		device: ^Device,
		textureD3D11Desc: ^TextureD3D11Desc,
		texture: ^^Texture,
	) -> Result,
}

@(default_calling_convention = "c", link_prefix = "nri")
foreign lib {
	CreateDeviceFromD3D11Device :: proc(deviceDesc: ^DeviceCreationD3D11Desc, device: ^^Device) -> Result ---
}

ID3D12Heap :: struct {}
ID3D12Fence :: struct {}
ID3D12Device :: struct {}
ID3D12Resource :: struct {}
ID3D12CommandQueue :: struct {}
ID3D12DescriptorHeap :: struct {}
ID3D12CommandAllocator :: struct {}
ID3D12GraphicsCommandList :: struct {}

QueueFamilyD3D12Desc :: struct {
	d3d12Queues: ^^ID3D12CommandQueue,
	queueNum:    u32,
	queueType:   QueueType,
}

DeviceCreationD3D12Desc :: struct {
	d3d12Device:                    ^ID3D12Device,
	queueFamilies:                  ^QueueFamilyD3D12Desc,
	queueFamilyNum:                 u32,
	agsContext:                     ^AGSContext,
	callbackInterface:              CallbackInterface,
	allocationCallbacks:            AllocationCallbacks,
	d3dShaderExtRegister:           u32,
	d3dZeroBufferSize:              u32,
	enableNRIValidation:            bool,
	enableMemoryZeroInitialization: bool,
	disableD3D12EnhancedBarriers:   bool,
	disableNVAPIInitialization:     bool,
}

CommandBufferD3D12Desc :: struct {
	d3d12CommandList:      ^ID3D12GraphicsCommandList,
	d3d12CommandAllocator: ^ID3D12CommandAllocator,
}

DescriptorPoolD3D12Desc :: struct {
	d3d12ResourceDescriptorHeap: ^ID3D12DescriptorHeap,
	d3d12SamplerDescriptorHeap:  ^ID3D12DescriptorHeap,
	descriptorSetMaxNum:         u32,
}

BufferD3D12Desc :: struct {
	d3d12Resource:   ^ID3D12Resource,
	desc:            ^BufferDesc,
	structureStride: u32,
}

TextureD3D12Desc :: struct {
	d3d12Resource: ^ID3D12Resource,
	format:        dxgi.FORMAT,
}

MemoryD3D12Desc :: struct {
	d3d12Heap: ^ID3D12Heap,
	offset:    u64,
}

FenceD3D12Desc :: struct {
	d3d12Fence: ^ID3D12Fence,
}

AccelerationStructureD3D12Desc :: struct {
	d3d12Resource:     ^ID3D12Resource,
	flags:             AccelerationStructureBits,
	size:              u64,
	buildScratchSize:  u64,
	updateScratchSize: u64,
}

WrapperD3D12Interface :: struct {
	CreateCommandBufferD3D12:         proc "c" (
		device: ^Device,
		commandBufferD3D12Desc: ^CommandBufferD3D12Desc,
		commandBuffer: ^^CommandBuffer,
	) -> Result,
	CreateDescriptorPoolD3D12:        proc "c" (
		device: ^Device,
		descriptorPoolD3D12Desc: ^DescriptorPoolD3D12Desc,
		descriptorPool: ^^DescriptorPool,
	) -> Result,
	CreateBufferD3D12:                proc "c" (
		device: ^Device,
		bufferD3D12Desc: ^BufferD3D12Desc,
		buffer: ^^Buffer,
	) -> Result,
	CreateTextureD3D12:               proc "c" (
		device: ^Device,
		textureD3D12Desc: ^TextureD3D12Desc,
		texture: ^^Texture,
	) -> Result,
	CreateMemoryD3D12:                proc "c" (
		device: ^Device,
		memoryD3D12Desc: ^MemoryD3D12Desc,
		memory: ^^Memory,
	) -> Result,
	CreateFenceD3D12:                 proc "c" (
		device: ^Device,
		fenceD3D12Desc: ^FenceD3D12Desc,
		fence: ^^Fence,
	) -> Result,
	CreateAccelerationStructureD3D12: proc "c" (
		device: ^Device,
		accelerationStructureD3D12Desc: ^AccelerationStructureD3D12Desc,
		accelerationStructure: ^^AccelerationStructure,
	) -> Result,
}

@(default_calling_convention = "c", link_prefix = "nri")
foreign lib {
	CreateDeviceFromD3D12Device :: proc(deviceDesc: ^DeviceCreationD3D12Desc, device: ^^Device) -> Result ---
}

VKHandle :: rawptr
VKEnum :: i32
VKFlags :: u32
VKNonDispatchableHandle :: u64

QueueFamilyVKDesc :: struct {
	queueNum:    u32,
	queueType:   QueueType,
	familyIndex: u32,
}

DeviceCreationVKDesc :: struct {
	callbackInterface:              CallbackInterface,
	allocationCallbacks:            AllocationCallbacks,
	libraryPath:                    cstring,
	vkBindingOffsets:               VKBindingOffsets,
	vkExtensions:                   VKExtensions,
	vkInstance:                     VKHandle,
	vkDevice:                       VKHandle,
	vkPhysicalDevice:               VKHandle,
	queueFamilies:                  ^QueueFamilyVKDesc,
	queueFamilyNum:                 u32,
	minorVersion:                   u8,
	enableNRIValidation:            bool,
	enableMemoryZeroInitialization: bool,
}

CommandAllocatorVKDesc :: struct {
	vkCommandPool: VKNonDispatchableHandle,
	queueType:     QueueType,
}

CommandBufferVKDesc :: struct {
	vkCommandBuffer: VKHandle,
	queueType:       QueueType,
}

DescriptorPoolVKDesc :: struct {
	vkDescriptorPool:    VKNonDispatchableHandle,
	descriptorSetMaxNum: u32,
}

BufferVKDesc :: struct {
	vkBuffer:        VKNonDispatchableHandle,
	size:            u64,
	structureStride: u32,
	mappedMemory:    ^u8,
	vkDeviceMemory:  VKNonDispatchableHandle,
	deviceAddress:   u64,
}

TextureVKDesc :: struct {
	vkImage:     VKNonDispatchableHandle,
	vkFormat:    VKEnum,
	vkImageType: VKEnum,
	width:       Dim_t,
	height:      Dim_t,
	depth:       Dim_t,
	mipNum:      Dim_t,
	layerNum:    Dim_t,
	sampleNum:   Sample_t,
}

MemoryVKDesc :: struct {
	vkDeviceMemory:  VKNonDispatchableHandle,
	offset:          u64,
	mappedMemory:    rawptr,
	size:            u64,
	memoryTypeIndex: u32,
}

PipelineVKDesc :: struct {
	vkPipeline:          VKNonDispatchableHandle,
	vkPipelineBindPoint: VKEnum,
}

QueryPoolVKDesc :: struct {
	vkQueryPool: VKNonDispatchableHandle,
	vkQueryType: VKEnum,
}

FenceVKDesc :: struct {
	vkTimelineSemaphore: VKNonDispatchableHandle,
}

AccelerationStructureVKDesc :: struct {
	vkAccelerationStructure: VKNonDispatchableHandle,
	vkBuffer:                VKNonDispatchableHandle,
	bufferSize:              u64,
	buildScratchSize:        u64,
	updateScratchSize:       u64,
	flags:                   AccelerationStructureBits,
}

WrapperVKInterface :: struct {
	CreateCommandAllocatorVK:      proc "c" (
		device: ^Device,
		commandAllocatorVKDesc: ^CommandAllocatorVKDesc,
		commandAllocator: ^^CommandAllocator,
	) -> Result,
	CreateCommandBufferVK:         proc "c" (
		device: ^Device,
		commandBufferVKDesc: ^CommandBufferVKDesc,
		commandBuffer: ^^CommandBuffer,
	) -> Result,
	CreateDescriptorPoolVK:        proc "c" (
		device: ^Device,
		descriptorPoolVKDesc: ^DescriptorPoolVKDesc,
		descriptorPool: ^^DescriptorPool,
	) -> Result,
	CreateBufferVK:                proc "c" (
		device: ^Device,
		bufferVKDesc: ^BufferVKDesc,
		buffer: ^^Buffer,
	) -> Result,
	CreateTextureVK:               proc "c" (
		device: ^Device,
		textureVKDesc: ^TextureVKDesc,
		texture: ^^Texture,
	) -> Result,
	CreateMemoryVK:                proc "c" (
		device: ^Device,
		memoryVKDesc: ^MemoryVKDesc,
		memory: ^^Memory,
	) -> Result,
	CreatePipelineVK:              proc "c" (
		device: ^Device,
		pipelineVKDesc: ^PipelineVKDesc,
		pipeline: ^^Pipeline,
	) -> Result,
	CreateQueryPoolVK:             proc "c" (
		device: ^Device,
		queryPoolVKDesc: ^QueryPoolVKDesc,
		queryPool: ^^QueryPool,
	) -> Result,
	CreateFenceVK:                 proc "c" (
		device: ^Device,
		fenceVKDesc: ^FenceVKDesc,
		fence: ^^Fence,
	) -> Result,
	CreateAccelerationStructureVK: proc "c" (
		device: ^Device,
		accelerationStructureVKDesc: ^AccelerationStructureVKDesc,
		accelerationStructure: ^^AccelerationStructure,
	) -> Result,
	GetQueueFamilyIndexVK:         proc "c" (queue: ^Queue) -> u32,
	GetPhysicalDeviceVK:           proc "c" (device: ^Device) -> VKHandle,
	GetInstanceVK:                 proc "c" (device: ^Device) -> VKHandle,
	GetInstanceProcAddrVK:         proc "c" (device: ^Device) -> rawptr,
	GetDeviceProcAddrVK:           proc "c" (device: ^Device) -> rawptr,
}

@(default_calling_convention = "c", link_prefix = "nri")
foreign lib {
	CreateDeviceFromVKDevice :: proc(deviceDesc: ^DeviceCreationVKDesc, device: ^^Device) -> Result ---
}
