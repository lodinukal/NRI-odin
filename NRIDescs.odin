// © 2021 NVIDIA Corporation
package NRI

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

Fence :: struct {} // a synchronization primitive that can be used to insert a dependency between queue operations or between a queue operation and the host
Queue :: struct {} // a logical queue, providing access to a HW queue
Memory :: struct {} // a memory blob allocated on DEVICE or HOST
Buffer :: struct {} // a buffer object: linear arrays of data
Device :: struct {} // a logical device
Texture :: struct {} // a texture object: multidimensional arrays of data
Pipeline :: struct {} // a collection of state needed for rendering: shaders + fixed
SwapChain :: struct {} // an array of presentable images that are associated with a surface
QueryPool :: struct {} // a collection of queries of the same type
Descriptor :: struct {} // a handle or pointer to a resource (potentially with a header)
CommandBuffer :: struct {} // used to record commands which can be subsequently submitted to a device queue for execution (aka command list)
DescriptorSet :: struct {} // a continuous set of descriptors
DescriptorPool :: struct {} // maintains a pool of descriptors, descriptor sets are allocated from (aka descriptor heap)
PipelineLayout :: struct {} // determines the interface between shader stages and shader resources (aka root signature)
CommandAllocator :: struct {} // an object that command buffer memory is allocated from

// Basic types
Sample_t :: u8
Dim_t :: u16
Object :: struct {}

Uid_t :: struct {
	low:  u64,
	high: u64,
}

Dim2_t :: struct {
	w, h: Dim_t,
}

Float2_t :: struct {
	x, y: f32,
}

//============================================================================================================================================================================================
GraphicsAPI :: enum i32 {
	//============================================================================================================================================================================================
	NONE    = 0,

	//============================================================================================================================================================================================
	D3D11   = 1,

	//============================================================================================================================================================================================
	D3D12   = 2,

	//============================================================================================================================================================================================
	VK      = 3,

	//============================================================================================================================================================================================
	MAX_NUM = 4,
}

Result :: enum i32 {
	DEVICE_LOST      = -3,
	OUT_OF_DATE      = -2,
	INVALID_SDK      = -1,
	SUCCESS          = 0,
	FAILURE          = 1,
	INVALID_ARGUMENT = 2,
	OUT_OF_MEMORY    = 3,
	UNSUPPORTED      = 4,
	MAX_NUM          = 5,
}

// The viewport origin is top-left (D3D native) by default, but can be changed to bottom-left (VK native)
// https://registry.khronos.org/vulkan/specs/latest/man/html/VkViewport.html
// https://learn.microsoft.com/en-us/windows/win32/api/d3d12/ns-d3d12-d3d12_viewport
Viewport :: struct {
	x:                f32,
	y:                f32,
	width:            f32,
	height:           f32,
	depthMin:         f32,
	depthMax:         f32,
	originBottomLeft: bool, // expects "features.viewportOriginBottomLeft"
}

// https://registry.khronos.org/vulkan/specs/latest/man/html/VkRect2D.html
Rect :: struct {
	x:      i16,
	y:      i16,
	width:  Dim_t,
	height: Dim_t,
}

Color32f :: struct {
	x, y, z, w: f32,
}

Color32ui :: struct {
	x, y, z, w: u32,
}

Color32i :: struct {
	x, y, z, w: i32,
}

DepthStencil :: struct {
	depth:   f32,
	stencil: u8,
}

Color :: struct #raw_union {
	f:  Color32f,
	ui: Color32ui,
	i:  Color32i,
}

ClearValue :: struct #raw_union {
	depthStencil: DepthStencil,
	color:        Color,
}

SampleLocation :: struct {
	x, y: i8, // [-8; 7]
}

// https://registry.khronos.org/vulkan/specs/latest/man/html/VkFormat.html
// https://learn.microsoft.com/en-us/windows/win32/api/dxgiformat/ne-dxgiformat-dxgi_format
// left -> right : low -> high bits
// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
// To demote sRGB use the previous format, i.e. "format - 1"
//                                                STORAGE_BUFFER_ATOMICS
//                                                      VERTEX_BUFFER  |
//                                                  STORAGE_BUFFER  |  |
//                                                       BUFFER  |  |  |
//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
//                                                  BLEND  |  |  |  |  |
//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
//                                    TEXTURE  |  |  |  |  |  |  |  |  |
//                                          |  |  |  |  |  |  |  |  |  |
//                                          |    FormatSupportBits     |
Format :: enum u8 {
	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	UNKNOWN                = 0,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	R8_UNORM               = 1,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	R8_SNORM               = 2,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	R8_UINT                = 3,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	R8_SINT                = 4,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	RG8_UNORM              = 5,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	RG8_SNORM              = 6,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	RG8_UINT               = 7,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	RG8_SINT               = 8,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	BGRA8_UNORM            = 9,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	BGRA8_SRGB             = 10,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	RGBA8_UNORM            = 11,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	RGBA8_SRGB             = 12,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	RGBA8_SNORM            = 13,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	RGBA8_UINT             = 14,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	RGBA8_SINT             = 15,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	R16_UNORM              = 16,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	R16_SNORM              = 17,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	R16_UINT               = 18,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	R16_SINT               = 19,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	R16_SFLOAT             = 20,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	RG16_UNORM             = 21,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	RG16_SNORM             = 22,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	RG16_UINT              = 23,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	RG16_SINT              = 24,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	RG16_SFLOAT            = 25,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	RGBA16_UNORM           = 26,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	RGBA16_SNORM           = 27,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	RGBA16_UINT            = 28,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	RGBA16_SINT            = 29,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	RGBA16_SFLOAT          = 30,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	R32_UINT               = 31,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	R32_SINT               = 32,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	R32_SFLOAT             = 33,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	RG32_UINT              = 34,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	RG32_SINT              = 35,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	RG32_SFLOAT            = 36,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	RGB32_UINT             = 37,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	RGB32_SINT             = 38,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	RGB32_SFLOAT           = 39,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	RGBA32_UINT            = 40,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	RGBA32_SINT            = 41,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	RGBA32_SFLOAT          = 42,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	B5_G6_R5_UNORM         = 43,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	B5_G5_R5_A1_UNORM      = 44,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	B4_G4_R4_A4_UNORM      = 45,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	R10_G10_B10_A2_UNORM   = 46,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	R10_G10_B10_A2_UINT    = 47,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	R11_G11_B10_UFLOAT     = 48,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	R9_G9_B9_E5_UFLOAT     = 49,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	BC1_RGBA_UNORM         = 50,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	BC1_RGBA_SRGB          = 51,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	BC2_RGBA_UNORM         = 52,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	BC2_RGBA_SRGB          = 53,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	BC3_RGBA_UNORM         = 54,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	BC3_RGBA_SRGB          = 55,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	BC4_R_UNORM            = 56,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	BC4_R_SNORM            = 57,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	BC5_RG_UNORM           = 58,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	BC5_RG_SNORM           = 59,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	BC6H_RGB_UFLOAT        = 60,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	BC6H_RGB_SFLOAT        = 61,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	BC7_RGBA_UNORM         = 62,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	BC7_RGBA_SRGB          = 63,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	D16_UNORM              = 64,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	D24_UNORM_S8_UINT      = 65,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	D32_SFLOAT             = 66,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	D32_SFLOAT_S8_UINT_X24 = 67,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	R24_UNORM_X8           = 68,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	X24_G8_UINT            = 69,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	R32_SFLOAT_X8_X24      = 70,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	X32_G8_UINT_X24        = 71,

	// left -> right : low -> high bits
	// Expected (but not guaranteed) "FormatSupportBits" are provided, but "GetFormatSupport" should be used for querying real HW support
	// To demote sRGB use the previous format, i.e. "format - 1"
	//                                                STORAGE_BUFFER_ATOMICS
	//                                                      VERTEX_BUFFER  |
	//                                                  STORAGE_BUFFER  |  |
	//                                                       BUFFER  |  |  |
	//                                   STORAGE_TEXTURE_ATOMICS  |  |  |  |
	//                                                  BLEND  |  |  |  |  |
	//                            DEPTH_STENCIL_ATTACHMENT  |  |  |  |  |  |
	//                                 COLOR_ATTACHMENT  |  |  |  |  |  |  |
	//                               STORAGE_TEXTURE  |  |  |  |  |  |  |  |
	//                                    TEXTURE  |  |  |  |  |  |  |  |  |
	//                                          |  |  |  |  |  |  |  |  |  |
	//                                          |    FormatSupportBits     |
	MAX_NUM                = 72,
}

PlaneBitsEnum :: enum i32 {
	COLOR   = 0,
	DEPTH   = 1,
	STENCIL = 2,
}

// https://learn.microsoft.com/en-us/windows/win32/direct3d12/subresources#plane-slice
// https://registry.khronos.org/vulkan/specs/latest/man/html/VkImageAspectFlagBits.html
PlaneBits :: bit_set[PlaneBitsEnum;u8]

FormatSupportBitsEnum :: enum i32 {
	// A bit represents a feature, supported by a format
	TEXTURE                      = 0,

	// A bit represents a feature, supported by a format
	STORAGE_TEXTURE              = 1,

	// A bit represents a feature, supported by a format
	STORAGE_TEXTURE_ATOMICS      = 2,

	// A bit represents a feature, supported by a format
	COLOR_ATTACHMENT             = 3,

	// A bit represents a feature, supported by a format
	DEPTH_STENCIL_ATTACHMENT     = 4,

	// A bit represents a feature, supported by a format
	BLEND                        = 5,

	// A bit represents a feature, supported by a format
	MULTISAMPLE_2X               = 6,

	// A bit represents a feature, supported by a format
	MULTISAMPLE_4X               = 7,

	// A bit represents a feature, supported by a format
	MULTISAMPLE_8X               = 8,

	// A bit represents a feature, supported by a format
	BUFFER                       = 9,

	// A bit represents a feature, supported by a format
	STORAGE_BUFFER               = 10,

	// A bit represents a feature, supported by a format
	STORAGE_BUFFER_ATOMICS       = 11,

	// A bit represents a feature, supported by a format
	VERTEX_BUFFER                = 12,

	// A bit represents a feature, supported by a format
	STORAGE_READ_WITHOUT_FORMAT  = 13,

	// A bit represents a feature, supported by a format
	STORAGE_WRITE_WITHOUT_FORMAT = 14,
}

// A bit represents a feature, supported by a format
FormatSupportBits :: bit_set[FormatSupportBitsEnum;u16]

StageBitsEnum :: enum i32 {
	INDEX_INPUT              = 0,
	VERTEX_SHADER            = 1,
	TESS_CONTROL_SHADER      = 2,
	TESS_EVALUATION_SHADER   = 3,
	GEOMETRY_SHADER          = 4,
	TASK_SHADER              = 5,
	MESH_SHADER              = 6,
	FRAGMENT_SHADER          = 7,
	DEPTH_STENCIL_ATTACHMENT = 8,
	COLOR_ATTACHMENT         = 9,
	COMPUTE_SHADER           = 10,
	RAYGEN_SHADER            = 11,
	MISS_SHADER              = 12,
	INTERSECTION_SHADER      = 13,
	CLOSEST_HIT_SHADER       = 14,
	ANY_HIT_SHADER           = 15,
	CALLABLE_SHADER          = 16,
	ACCELERATION_STRUCTURE   = 17,
	MICROMAP                 = 18,
	COPY                     = 19,
	RESOLVE                  = 20,
	CLEAR_STORAGE            = 21,
	INDIRECT                 = 22,
}

// https://registry.khronos.org/vulkan/specs/latest/man/html/VkPipelineStageFlagBits2.html
// https://microsoft.github.io/DirectX-Specs/d3d/D3D12EnhancedBarriers.html#d3d12_barrier_sync
StageBits :: bit_set[StageBitsEnum;u32]
STAGEBITS_ALL_SHADERS :: StageBits {
	.VERTEX_SHADER,
	.TESS_CONTROL_SHADER,
	.TESS_EVALUATION_SHADER,
	.GEOMETRY_SHADER,
	.TASK_SHADER,
	.MESH_SHADER,
	.FRAGMENT_SHADER,
	.COMPUTE_SHADER,
	.RAYGEN_SHADER,
	.MISS_SHADER,
	.INTERSECTION_SHADER,
	.CLOSEST_HIT_SHADER,
	.ANY_HIT_SHADER,
	.CALLABLE_SHADER,
}
STAGEBITS_MESH_SHADERS :: StageBits{.TASK_SHADER, .MESH_SHADER}
STAGEBITS_TESSELLATION_SHADERS :: StageBits{.TESS_CONTROL_SHADER, .TESS_EVALUATION_SHADER}
STAGEBITS_GRAPHICS :: StageBits {
	.INDEX_INPUT,
	.VERTEX_SHADER,
	.TESS_CONTROL_SHADER,
	.TESS_EVALUATION_SHADER,
	.GEOMETRY_SHADER,
	.TASK_SHADER,
	.MESH_SHADER,
	.FRAGMENT_SHADER,
	.DEPTH_STENCIL_ATTACHMENT,
	.COLOR_ATTACHMENT,
}
STAGEBITS_NONE :: StageBits {
	.INDEX_INPUT,
	.VERTEX_SHADER,
	.TESS_CONTROL_SHADER,
	.TESS_EVALUATION_SHADER,
	.GEOMETRY_SHADER,
	.TASK_SHADER,
	.MESH_SHADER,
	.FRAGMENT_SHADER,
	.DEPTH_STENCIL_ATTACHMENT,
	.COLOR_ATTACHMENT,
	.COMPUTE_SHADER,
	.RAYGEN_SHADER,
	.MISS_SHADER,
	.INTERSECTION_SHADER,
	.CLOSEST_HIT_SHADER,
	.ANY_HIT_SHADER,
	.CALLABLE_SHADER,
	.ACCELERATION_STRUCTURE,
	.MICROMAP,
	.COPY,
	.RESOLVE,
	.CLEAR_STORAGE,
	.INDIRECT,
}
STAGEBITS_RAY_TRACING_SHADERS :: StageBits {
	.RAYGEN_SHADER,
	.MISS_SHADER,
	.INTERSECTION_SHADER,
	.CLOSEST_HIT_SHADER,
	.ANY_HIT_SHADER,
	.CALLABLE_SHADER,
}
STAGEBITS_GRAPHICS_SHADERS :: StageBits {
	.VERTEX_SHADER,
	.TESS_CONTROL_SHADER,
	.TESS_EVALUATION_SHADER,
	.GEOMETRY_SHADER,
	.TASK_SHADER,
	.MESH_SHADER,
	.FRAGMENT_SHADER,
}

AccessBitsEnum :: enum i32 {
	INDEX_BUFFER                   = 0,
	VERTEX_BUFFER                  = 1,
	CONSTANT_BUFFER                = 2,
	ARGUMENT_BUFFER                = 3,
	SCRATCH_BUFFER                 = 4,
	COLOR_ATTACHMENT               = 5,
	SHADING_RATE_ATTACHMENT        = 6,
	DEPTH_STENCIL_ATTACHMENT_READ  = 7,
	DEPTH_STENCIL_ATTACHMENT_WRITE = 8,
	ACCELERATION_STRUCTURE_READ    = 9,
	ACCELERATION_STRUCTURE_WRITE   = 10,
	MICROMAP_READ                  = 11,
	MICROMAP_WRITE                 = 12,
	SHADER_RESOURCE                = 13,
	SHADER_RESOURCE_STORAGE        = 14,
	SHADER_BINDING_TABLE           = 15,
	COPY_SOURCE                    = 16,
	COPY_DESTINATION               = 17,
	RESOLVE_SOURCE                 = 18,
	RESOLVE_DESTINATION            = 19,
	CLEAR_STORAGE                  = 20,
}

// https://registry.khronos.org/vulkan/specs/latest/man/html/VkAccessFlagBits2.html
// https://microsoft.github.io/DirectX-Specs/d3d/D3D12EnhancedBarriers.html#d3d12_barrier_access
AccessBits :: bit_set[AccessBitsEnum;u32]

// "Layout" is ignored if "features.enhancedBarriers" is not supported
// https://registry.khronos.org/vulkan/specs/latest/man/html/VkImageLayout.html
// https://microsoft.github.io/DirectX-Specs/d3d/D3D12EnhancedBarriers.html#d3d12_barrier_layout
Layout :: enum i32 {
	UNDEFINED                = 0, // Compatible "AccessBits":
	GENERAL                  = 1, // Compatible "AccessBits":
	PRESENT                  = 2, // Compatible "AccessBits":
	COLOR_ATTACHMENT         = 3, // Compatible "AccessBits":
	SHADING_RATE_ATTACHMENT  = 4, // Compatible "AccessBits":
	DEPTH_STENCIL_ATTACHMENT = 5, // Compatible "AccessBits":
	DEPTH_STENCIL_READONLY   = 6, // Compatible "AccessBits":
	SHADER_RESOURCE          = 7, // Compatible "AccessBits":
	SHADER_RESOURCE_STORAGE  = 8, // Compatible "AccessBits":
	COPY_SOURCE              = 9, // Compatible "AccessBits":
	COPY_DESTINATION         = 10, // Compatible "AccessBits":
	RESOLVE_SOURCE           = 11, // Compatible "AccessBits":
	RESOLVE_DESTINATION      = 12, // Compatible "AccessBits":
	MAX_NUM                  = 13, // Compatible "AccessBits":
} // Compatible "AccessBits":

AccessStage :: struct {
	access: AccessBits,
	stages: StageBits,
}

AccessLayoutStage :: struct {
	access: AccessBits,
	layout: Layout,
	stages: StageBits,
}

GlobalBarrierDesc :: struct {
	before: AccessStage,
	after:  AccessStage,
}

BufferBarrierDesc :: struct {
	buffer: ^Buffer, // use "GetAccelerationStructureBuffer" and "GetMicromapBuffer" for related barriers
	before: AccessStage,
	after:  AccessStage,
}

TextureBarrierDesc :: struct {
	texture:     ^Texture,
	before:      AccessLayoutStage,
	after:       AccessLayoutStage,
	mipOffset:   Dim_t,
	mipNum:      Dim_t, // can be "REMAINING"
	layerOffset: Dim_t,
	layerNum:    Dim_t, // can be "REMAINING"
	planes:      PlaneBits,
	srcQueue:    ^Queue,
	dstQueue:    ^Queue,
}

BarrierDesc :: struct {
	globals:    ^GlobalBarrierDesc,
	globalNum:  u32,
	buffers:    ^BufferBarrierDesc,
	bufferNum:  u32,
	textures:   ^TextureBarrierDesc,
	textureNum: u32,
}

// https://registry.khronos.org/vulkan/specs/latest/man/html/VkImageType.html
// https://learn.microsoft.com/en-us/windows/win32/api/d3d12/ne-d3d12-d3d12_resource_dimension
TextureType :: enum u8 {
	TEXTURE_1D = 0,
	TEXTURE_2D = 1,
	TEXTURE_3D = 2,
	MAX_NUM    = 3,
}

// NRI tries to ease your life and avoid using "queue ownership transfers" (see "TextureBarrierDesc").
// In most of cases "SharingMode" can be ignored. Where is it needed?
// - VK: use "EXCLUSIVE" for attachments participating into multi-queue activities to preserve DCC (Delta Color Compression) on some HW
// - D3D12: use "SIMULTANEOUS" to concurrently use a texture as a "SHADER_RESOURCE" (or "SHADER_RESOURCE_STORAGE") and as a "COPY_DESTINATION" for non overlapping texture regions
// https://registry.khronos.org/vulkan/specs/latest/man/html/VkSharingMode.html
SharingMode :: enum u8 {
	CONCURRENT   = 0,
	EXCLUSIVE    = 1,
	SIMULTANEOUS = 2,
	MAX_NUM      = 3,
}

TextureUsageBitsEnum :: enum i32 {
	SHADER_RESOURCE          = 0, // Min compatible access:                  Usage:
	SHADER_RESOURCE_STORAGE  = 1, // Min compatible access:                  Usage:
	COLOR_ATTACHMENT         = 2, // Min compatible access:                  Usage:
	DEPTH_STENCIL_ATTACHMENT = 3, // Min compatible access:                  Usage:
	SHADING_RATE_ATTACHMENT  = 4, // Min compatible access:                  Usage:
}

// https://registry.khronos.org/vulkan/specs/latest/man/html/VkImageUsageFlagBits.html
// https://learn.microsoft.com/en-us/windows/win32/api/d3d12/ne-d3d12-d3d12_resource_flags
TextureUsageBits :: bit_set[TextureUsageBitsEnum;u8] // Min compatible access:                  Usage:

BufferUsageBitsEnum :: enum i32 {
	SHADER_RESOURCE                    = 0, // Min compatible access:                  Usage:
	SHADER_RESOURCE_STORAGE            = 1, // Min compatible access:                  Usage:
	VERTEX_BUFFER                      = 2, // Min compatible access:                  Usage:
	INDEX_BUFFER                       = 3, // Min compatible access:                  Usage:
	CONSTANT_BUFFER                    = 4, // Min compatible access:                  Usage:
	ARGUMENT_BUFFER                    = 5, // Min compatible access:                  Usage:
	SCRATCH_BUFFER                     = 6, // Min compatible access:                  Usage:
	SHADER_BINDING_TABLE               = 7, // Min compatible access:                  Usage:
	ACCELERATION_STRUCTURE_BUILD_INPUT = 8, // Min compatible access:                  Usage:
	ACCELERATION_STRUCTURE_STORAGE     = 9, // Min compatible access:                  Usage:
	MICROMAP_BUILD_INPUT               = 10, // Min compatible access:                  Usage:
	MICROMAP_STORAGE                   = 11, // Min compatible access:                  Usage:
}

// https://registry.khronos.org/vulkan/specs/latest/man/html/VkBufferUsageFlagBits.html
BufferUsageBits :: bit_set[BufferUsageBitsEnum;u16] // Min compatible access:                  Usage:

TextureDesc :: struct {
	type:                TextureType,
	usage:               TextureUsageBits,
	format:              Format,
	width:               Dim_t,
	height:              Dim_t,
	depth:               Dim_t,
	mipNum:              Dim_t,
	layerNum:            Dim_t,
	sampleNum:           Sample_t,
	sharingMode:         SharingMode,
	optimizedClearValue: ClearValue, // D3D12: not needed on desktop, since any HW can track many clear values
}

// "structureStride" values:
// 0  = allows "typed" views
// 4  = allows "typed", "byte address" (raw) and "structured" views (D3D11: allows to create multiple "structured" views for a single resource, disobeying the spec)
// >4 = allows "structured" and potentially "typed" views (D3D11: locks this buffer to a single "structured" layout, no "typed" views)
// VK: buffers always created with sharing mode "CONCURRENT" to match D3D12 spec
BufferDesc :: struct {
	size:            u64,
	structureStride: u32,
	usage:           BufferUsageBits,
}

// Contains some encoded implementation specific details
MemoryType :: u32

// https://learn.microsoft.com/en-us/windows/win32/api/d3d12/ne-d3d12-d3d12_heap_type
MemoryLocation :: enum u8 {
	DEVICE        = 0,
	DEVICE_UPLOAD = 1,
	HOST_UPLOAD   = 2,
	HOST_READBACK = 3,
	MAX_NUM       = 4,
}

// Memory requirements for a resource (buffer or texture)
MemoryDesc :: struct {
	size:            u64,
	alignment:       u32,
	type:            MemoryType,
	mustBeDedicated: bool, // must be put into a dedicated "Memory" object, containing only 1 object with offset = 0
}

// A group of non-dedicated "MemoryDesc"s of the SAME "MemoryType" can be merged into a single memory allocation
AllocateMemoryDesc :: struct {
	size:                     u64,
	type:                     MemoryType,
	priority:                 f32, // [-1; 1]: low < 0, normal = 0, high > 0
	vma:                      struct {
		enable:    bool,
		alignment: u32, // by default worst-case alignment applied
	},

	// If "false", may reduce alignment requirements
	allowMultisampleTextures: bool,
}

// Binding resources to a memory (resources can overlap, i.e. alias)
BindBufferMemoryDesc :: struct {
	buffer: ^Buffer,
	memory: ^Memory,
	offset: u64, // in memory
}

BindTextureMemoryDesc :: struct {
	texture: ^Texture,
	memory:  ^Memory,
	offset:  u64, // in memory
}

// https://microsoft.github.io/DirectX-Specs/d3d/ResourceBinding.html#creating-descriptors
Texture1DViewType :: enum u8 {
	SHADER_RESOURCE_1D                = 0,
	SHADER_RESOURCE_1D_ARRAY          = 1,
	SHADER_RESOURCE_STORAGE_1D        = 2,
	SHADER_RESOURCE_STORAGE_1D_ARRAY  = 3,
	COLOR_ATTACHMENT                  = 4,
	DEPTH_STENCIL_ATTACHMENT          = 5,
	DEPTH_READONLY_STENCIL_ATTACHMENT = 6,
	DEPTH_ATTACHMENT_STENCIL_READONLY = 7,
	DEPTH_STENCIL_READONLY            = 8,
	MAX_NUM                           = 9,
}

Texture2DViewType :: enum u8 {
	SHADER_RESOURCE_2D                = 0,
	SHADER_RESOURCE_2D_ARRAY          = 1,
	SHADER_RESOURCE_CUBE              = 2,
	SHADER_RESOURCE_CUBE_ARRAY        = 3,
	SHADER_RESOURCE_STORAGE_2D        = 4,
	SHADER_RESOURCE_STORAGE_2D_ARRAY  = 5,
	COLOR_ATTACHMENT                  = 6,
	DEPTH_STENCIL_ATTACHMENT          = 7,
	DEPTH_READONLY_STENCIL_ATTACHMENT = 8,
	DEPTH_ATTACHMENT_STENCIL_READONLY = 9,
	DEPTH_STENCIL_READONLY            = 10,
	SHADING_RATE_ATTACHMENT           = 11,
	MAX_NUM                           = 12,
}

Texture3DViewType :: enum u8 {
	SHADER_RESOURCE_3D         = 0,
	SHADER_RESOURCE_STORAGE_3D = 1,
	COLOR_ATTACHMENT           = 2,
	MAX_NUM                    = 3,
}

BufferViewType :: enum u8 {
	SHADER_RESOURCE         = 0,
	SHADER_RESOURCE_STORAGE = 1,
	CONSTANT                = 2,
	MAX_NUM                 = 3,
}

// https://registry.khronos.org/vulkan/specs/latest/man/html/VkFilter.html
// https://registry.khronos.org/vulkan/specs/latest/man/html/VkSamplerMipmapMode.html
// https://learn.microsoft.com/en-us/windows/win32/api/d3d12/ne-d3d12-d3d12_filter
Filter :: enum u8 {
	NEAREST = 0,
	LINEAR  = 1,
	MAX_NUM = 2,
}

// https://registry.khronos.org/vulkan/specs/latest/man/html/VkSamplerReductionMode.html
ReductionMode :: enum u8 {
	AVERAGE = 0,
	MIN     = 1,
	MAX     = 2,
	MAX_NUM = 3,
}

// https://registry.khronos.org/vulkan/specs/latest/man/html/VkSamplerAddressMode.html
// https://learn.microsoft.com/en-us/windows/win32/api/d3d12/ne-d3d12-d3d12_texture_address_mode
AddressMode :: enum u8 {
	REPEAT               = 0,
	MIRRORED_REPEAT      = 1,
	CLAMP_TO_EDGE        = 2,
	CLAMP_TO_BORDER      = 3,
	MIRROR_CLAMP_TO_EDGE = 4,
	MAX_NUM              = 5,
}

// https://registry.khronos.org/vulkan/specs/latest/man/html/VkCompareOp.html
// https://learn.microsoft.com/en-us/windows/win32/api/d3d12/ne-d3d12-d3d12_comparison_func
// R - fragment depth, stencil reference or "SampleCmp" reference
// D - depth or stencil buffer
CompareOp :: enum u8 {
	// R - fragment depth, stencil reference or "SampleCmp" reference
	// D - depth or stencil buffer
	NONE          = 0,

	// R - fragment depth, stencil reference or "SampleCmp" reference
	// D - depth or stencil buffer
	ALWAYS        = 1,

	// R - fragment depth, stencil reference or "SampleCmp" reference
	// D - depth or stencil buffer
	NEVER         = 2,

	// R - fragment depth, stencil reference or "SampleCmp" reference
	// D - depth or stencil buffer
	EQUAL         = 3,

	// R - fragment depth, stencil reference or "SampleCmp" reference
	// D - depth or stencil buffer
	NOT_EQUAL     = 4,

	// R - fragment depth, stencil reference or "SampleCmp" reference
	// D - depth or stencil buffer
	LESS          = 5,

	// R - fragment depth, stencil reference or "SampleCmp" reference
	// D - depth or stencil buffer
	LESS_EQUAL    = 6,

	// R - fragment depth, stencil reference or "SampleCmp" reference
	// D - depth or stencil buffer
	GREATER       = 7,

	// R - fragment depth, stencil reference or "SampleCmp" reference
	// D - depth or stencil buffer
	GREATER_EQUAL = 8,

	// R - fragment depth, stencil reference or "SampleCmp" reference
	// D - depth or stencil buffer
	MAX_NUM       = 9,
}

Texture1DViewDesc :: struct {
	texture:     ^Texture,
	viewType:    Texture1DViewType,
	format:      Format,
	mipOffset:   Dim_t,
	mipNum:      Dim_t, // can be "REMAINING"
	layerOffset: Dim_t,
	layerNum:    Dim_t, // can be "REMAINING"
}

Texture2DViewDesc :: struct {
	texture:     ^Texture,
	viewType:    Texture2DViewType,
	format:      Format,
	mipOffset:   Dim_t,
	mipNum:      Dim_t, // can be "REMAINING"
	layerOffset: Dim_t,
	layerNum:    Dim_t, // can be "REMAINING"
}

Texture3DViewDesc :: struct {
	texture:     ^Texture,
	viewType:    Texture3DViewType,
	format:      Format,
	mipOffset:   Dim_t,
	mipNum:      Dim_t, // can be "REMAINING"
	sliceOffset: Dim_t,
	sliceNum:    Dim_t, // can be "REMAINING"
}

BufferViewDesc :: struct {
	buffer:          ^Buffer,
	viewType:        BufferViewType,
	format:          Format,
	offset:          u64, // expects "memoryAlignment.bufferShaderResourceOffset" for shader resources
	size:            u64, // can be "WHOLE_SIZE"
	structureStride: u32, // = structure stride from "BufferDesc" if not provided
}

AddressModes :: struct {
	u, v, w: AddressMode,
}

Filters :: struct {
	min, mag, mip: Filter,
	ext:           ReductionMode, // requires "features.textureFilterMinMax"
}

// https://registry.khronos.org/vulkan/specs/latest/man/html/VkSamplerCreateInfo.html
// https://learn.microsoft.com/en-us/windows/win32/api/d3d12/ns-d3d12-d3d12_sampler_desc
SamplerDesc :: struct {
	filters:                 Filters,
	anisotropy:              u8,
	mipBias:                 f32,
	mipMin:                  f32,
	mipMax:                  f32,
	addressModes:            AddressModes,
	compareOp:               CompareOp,
	borderColor:             Color,
	isInteger:               bool,
	unnormalizedCoordinates: bool, // requires "shaderFeatures.unnormalizedCoordinates"
}

// https://registry.khronos.org/vulkan/specs/latest/man/html/VkPipelineBindPoint.html
BindPoint :: enum u8 {
	INHERIT     = 0,
	GRAPHICS    = 1,
	COMPUTE     = 2,
	RAY_TRACING = 3,
	MAX_NUM     = 4,
}

PipelineLayoutBitsEnum :: enum i32 {
	IGNORE_GLOBAL_SPIRV_OFFSETS            = 0,
	ENABLE_D3D12_DRAW_PARAMETERS_EMULATION = 1,
	SAMPLER_HEAP_DIRECTLY_INDEXED          = 2,
	RESOURCE_HEAP_DIRECTLY_INDEXED         = 3,
}

PipelineLayoutBits :: bit_set[PipelineLayoutBitsEnum;u8]

DescriptorPoolBitsEnum :: enum i32 {
	NriDescriptorPoolBits_ALLOW_UPDATE_AFTER_SET = 0,
}

DescriptorPoolBits :: bit_set[DescriptorPoolBitsEnum;u8]

DescriptorSetBitsEnum :: enum i32 {
	NriDescriptorSetBits_ALLOW_UPDATE_AFTER_SET = 0,
}

DescriptorSetBits :: bit_set[DescriptorSetBitsEnum;u8]

DescriptorRangeBitsEnum :: enum i32 {
	PARTIALLY_BOUND        = 0,
	ARRAY                  = 1,
	VARIABLE_SIZED_ARRAY   = 2,
	ALLOW_UPDATE_AFTER_SET = 3,
	MUTABLE                = 4,
}

// https://registry.khronos.org/vulkan/specs/latest/man/html/VkDescriptorBindingFlagBits.html
DescriptorRangeBits :: bit_set[DescriptorRangeBitsEnum;u8]

// https://registry.khronos.org/vulkan/specs/latest/man/html/VkDescriptorType.html
DescriptorType :: enum u8 {
	SAMPLER                   = 0,
	CONSTANT_BUFFER           = 1,
	TEXTURE                   = 2,
	STORAGE_TEXTURE           = 3,
	BUFFER                    = 4,
	STORAGE_BUFFER            = 5,
	STRUCTURED_BUFFER         = 6,
	STORAGE_STRUCTURED_BUFFER = 7,
	ACCELERATION_STRUCTURE    = 8,
	MAX_NUM                   = 9,
}

// "DescriptorRange" consists of "Descriptor" entities
DescriptorRangeDesc :: struct {
	baseRegisterIndex: u32,
	descriptorNum:     u32, // treated as max size if "VARIABLE_SIZED_ARRAY" flag is set
	descriptorType:    DescriptorType,
	shaderStages:      StageBits,
	flags:             DescriptorRangeBits,
}

// "DescriptorSet" consists of "DescriptorRange" entities
DescriptorSetDesc :: struct {
	registerSpace: u32, // must be unique, avoid big gaps
	ranges:        ^DescriptorRangeDesc,
	rangeNum:      u32,
	flags:         DescriptorSetBits,
}

// "PipelineLayout" consists of "DescriptorSet" descriptions and root parameters
RootConstantDesc :: struct {
	registerIndex: u32,
	size:          u32,
	shaderStages:  StageBits,
} // aka push constants block

RootDescriptorDesc :: struct {
	registerIndex:  u32,
	descriptorType: DescriptorType, // CONSTANT_BUFFER, STRUCTURED_BUFFER or STORAGE_STRUCTURED_BUFFER
	shaderStages:   StageBits,
} // aka push descriptor

// https://learn.microsoft.com/en-us/windows/win32/direct3d12/root-signature-limits#static-samplers
RootSamplerDesc :: struct {
	registerIndex: u32,
	desc:          SamplerDesc,
	shaderStages:  StageBits,
} // aka static (immutable) sampler

// https://registry.khronos.org/vulkan/specs/latest/man/html/VkPipelineLayoutCreateInfo.html
// https://microsoft.github.io/DirectX-Specs/d3d/ResourceBinding.html#root-signature
// https://microsoft.github.io/DirectX-Specs/d3d/ResourceBinding.html#root-signature-version-11
PipelineLayoutDesc :: struct {
	rootRegisterSpace: u32, // must be unique, avoid big gaps
	rootConstants:     ^RootConstantDesc,
	rootConstantNum:   u32,
	rootDescriptors:   ^RootDescriptorDesc,
	rootDescriptorNum: u32,
	rootSamplers:      ^RootSamplerDesc,
	rootSamplerNum:    u32,
	descriptorSets:    ^DescriptorSetDesc,
	descriptorSetNum:  u32,
	shaderStages:      StageBits,
	flags:             PipelineLayoutBits,
}

// Descriptor pool
// https://learn.microsoft.com/en-us/windows/win32/direct3d12/descriptor-heaps
// https://learn.microsoft.com/en-us/windows/win32/api/d3d12/ns-d3d12-d3d12_descriptor_heap_desc
// https://registry.khronos.org/vulkan/specs/latest/man/html/VkDescriptorPoolCreateInfo.html
DescriptorPoolDesc :: struct {
	// Maximum number of descriptor sets that can be allocated from this pool
	descriptorSetMaxNum:           u32,

	// Sampler heap:
	// - can be directly indexed in shaders if flag "SAMPLER_HEAP_DIRECTLY_INDEXED" is set
	// - root samplers do not count (not allocated from a descriptor pool)
	samplerMaxNum:                 u32, // number of "SAMPLER" descriptors

	// Resource heap:
	// - can be directly indexed in shaders if flag "RESOURCE_HEAP_DIRECTLY_INDEXED" is set
	// - a mutable descriptor is a proxy "union" descriptor for all resource descriptors
	// - a mutable descriptor must "mutate" to any non-mutable resource descriptor (i.e. non-sampler) via "UpdateDescriptorRanges" or "CopyDescriptorRanges"
	constantBufferMaxNum:          u32, // number of "CONSTANT_BUFFER" descriptors
	textureMaxNum:                 u32, // number of "TEXTURE" descriptors
	storageTextureMaxNum:          u32, // number of "STORAGE_TEXTURE" descriptors
	bufferMaxNum:                  u32, // number of "BUFFER" descriptors
	storageBufferMaxNum:           u32, // number of "STORAGE_BUFFER" descriptors
	structuredBufferMaxNum:        u32, // number of "STRUCTURED_BUFFER" descriptors
	storageStructuredBufferMaxNum: u32, // number of "STORAGE_STRUCTURED_BUFFER" descriptors
	accelerationStructureMaxNum:   u32, // number of "ACCELERATION_STRUCTURE" descriptors, requires "features.rayTracing"
	mutableMaxNum:                 u32, // number of descriptors for "DescriptorRangeBits::MUTABLE", requires "features.mutableDescriptorType"
	flags:                         DescriptorPoolBits,
}

// Updating/initializing descriptors in a descriptor set
UpdateDescriptorRangeDesc :: struct {
	// Destination
	descriptorSet:  ^DescriptorSet,
	rangeIndex:     u32,
	baseDescriptor: u32,

	// Source & count
	descriptors:    ^^Descriptor,
	descriptorNum:  u32,
}

// Copying descriptors between descriptor sets
CopyDescriptorRangeDesc :: struct {
	// Destination
	dstDescriptorSet:  ^DescriptorSet,
	dstRangeIndex:     u32,
	dstBaseDescriptor: u32,

	// Source & count
	srcDescriptorSet:  ^DescriptorSet,
	srcRangeIndex:     u32,
	srcBaseDescriptor: u32,
	descriptorNum:     u32, // can be "ALL" (source)
}

// Binding
SetDescriptorSetDesc :: struct {
	setIndex:      u32,
	descriptorSet: ^DescriptorSet,
	bindPoint:     BindPoint,
}

SetRootConstantsDesc :: struct {
	rootConstantIndex: u32,
	data:              rawptr,
	size:              u32,
	offset:            u32, // requires "features.rootConstantsOffset"
	bindPoint:         BindPoint,
} // requires "pipelineLayoutRootConstantMaxSize > 0"

SetRootDescriptorDesc :: struct {
	rootDescriptorIndex: u32,
	descriptor:          ^Descriptor,
	offset:              u32, // a non-"CONSTANT_BUFFER" descriptor requires "features.nonConstantBufferRootDescriptorOffset"
	bindPoint:           BindPoint,
} // requires "pipelineLayoutRootDescriptorMaxNum > 0"

//============================================================================================================================================================================================
IndexType :: enum u8 {
	//============================================================================================================================================================================================
	UINT16  = 0,

	//============================================================================================================================================================================================
	UINT32  = 1,

	//============================================================================================================================================================================================
	MAX_NUM = 2,
}

PrimitiveRestart :: enum u8 {
	DISABLED       = 0,
	INDICES_UINT16 = 1,
	INDICES_UINT32 = 2,
	MAX_NUM        = 3,
}

// https://registry.khronos.org/vulkan/specs/latest/man/html/VkVertexInputRate.html
VertexStreamStepRate :: enum u8 {
	PER_VERTEX   = 0,
	PER_INSTANCE = 1,
	MAX_NUM      = 2,
}

// https://registry.khronos.org/vulkan/specs/latest/man/html/VkPrimitiveTopology.html
// https://learn.microsoft.com/en-us/windows/win32/api/d3dcommon/ne-d3dcommon-d3d_primitive_topology
// https://learn.microsoft.com/en-us/windows/win32/api/d3d12/ne-d3d12-d3d12_primitive_topology_type
Topology :: enum u8 {
	POINT_LIST                    = 0,
	LINE_LIST                     = 1,
	LINE_STRIP                    = 2,
	TRIANGLE_LIST                 = 3,
	TRIANGLE_STRIP                = 4,
	LINE_LIST_WITH_ADJACENCY      = 5,
	LINE_STRIP_WITH_ADJACENCY     = 6,
	TRIANGLE_LIST_WITH_ADJACENCY  = 7,
	TRIANGLE_STRIP_WITH_ADJACENCY = 8,
	PATCH_LIST                    = 9,
	MAX_NUM                       = 10,
}

InputAssemblyDesc :: struct {
	topology:            Topology,
	tessControlPointNum: u8,
	primitiveRestart:    PrimitiveRestart,
}

VertexAttributeD3D :: struct {
	semanticName:  cstring,
	semanticIndex: u32,
}

VertexAttributeVK :: struct {
	location: u32,
}

VertexAttributeDesc :: struct {
	d3d:         VertexAttributeD3D,
	vk:          VertexAttributeVK,
	offset:      u32,
	format:      Format,
	streamIndex: u16,
}

VertexStreamDesc :: struct {
	bindingSlot: u16,
	stepRate:    VertexStreamStepRate,
}

VertexInputDesc :: struct {
	attributes:   ^VertexAttributeDesc,
	attributeNum: u8,
	streams:      ^VertexStreamDesc,
	streamNum:    u8,
}

VertexBufferDesc :: struct {
	buffer: ^Buffer,
	offset: u64,
	stride: u32,
}

// https://registry.khronos.org/vulkan/specs/latest/man/html/VkPolygonMode.html
// https://learn.microsoft.com/en-us/windows/win32/api/d3d12/ne-d3d12-d3d12_fill_mode
FillMode :: enum u8 {
	SOLID     = 0,
	WIREFRAME = 1,
	MAX_NUM   = 2,
}

// https://registry.khronos.org/vulkan/specs/latest/man/html/VkCullModeFlagBits.html
// https://learn.microsoft.com/en-us/windows/win32/api/d3d12/ne-d3d12-d3d12_cull_mode
CullMode :: enum u8 {
	NONE    = 0,
	FRONT   = 1,
	BACK    = 2,
	MAX_NUM = 3,
}

// https://docs.vulkan.org/samples/latest/samples/extensions/fragment_shading_rate_dynamic/README.html
// https://microsoft.github.io/DirectX-Specs/d3d/VariableRateShading.html
ShadingRate :: enum u8 {
	FRAGMENT_SIZE_1X1 = 0,
	FRAGMENT_SIZE_1X2 = 1,
	FRAGMENT_SIZE_2X1 = 2,
	FRAGMENT_SIZE_2X2 = 3,
	FRAGMENT_SIZE_2X4 = 4,
	FRAGMENT_SIZE_4X2 = 5,
	FRAGMENT_SIZE_4X4 = 6,
	MAX_NUM           = 7,
}

// https://registry.khronos.org/vulkan/specs/latest/man/html/VkFragmentShadingRateCombinerOpKHR.html
// https://learn.microsoft.com/en-us/windows/win32/api/d3d12/ne-d3d12-d3d12_shading_rate_combiner
//    "primitiveCombiner"      "attachmentCombiner"
// A   Pipeline shading rate    Result of Op1
// B   Primitive shading rate   Attachment shading rate
ShadingRateCombiner :: enum u8 {
	//    "primitiveCombiner"      "attachmentCombiner"
	// A   Pipeline shading rate    Result of Op1
	// B   Primitive shading rate   Attachment shading rate
	KEEP    = 0,

	//    "primitiveCombiner"      "attachmentCombiner"
	// A   Pipeline shading rate    Result of Op1
	// B   Primitive shading rate   Attachment shading rate
	REPLACE = 1,

	//    "primitiveCombiner"      "attachmentCombiner"
	// A   Pipeline shading rate    Result of Op1
	// B   Primitive shading rate   Attachment shading rate
	MIN     = 2,

	//    "primitiveCombiner"      "attachmentCombiner"
	// A   Pipeline shading rate    Result of Op1
	// B   Primitive shading rate   Attachment shading rate
	MAX     = 3,

	//    "primitiveCombiner"      "attachmentCombiner"
	// A   Pipeline shading rate    Result of Op1
	// B   Primitive shading rate   Attachment shading rate
	SUM     = 4,

	//    "primitiveCombiner"      "attachmentCombiner"
	// A   Pipeline shading rate    Result of Op1
	// B   Primitive shading rate   Attachment shading rate
	MAX_NUM = 5,
}

/*
https://registry.khronos.org/vulkan/specs/latest/html/vkspec.html#primsrast-depthbias-computation
https://learn.microsoft.com/en-us/windows/win32/direct3d11/d3d10-graphics-programming-guide-output-merger-stage-depth-bias
R - minimum resolvable difference
S - maximum slope

bias = constant * R + slopeFactor * S
if (clamp > 0)
bias = min(bias, clamp)
else if (clamp < 0)
bias = max(bias, clamp)

enabled if constant != 0 or slope != 0
*/
DepthBiasDesc :: struct {
	constant: f32,
	clamp:    f32,
	slope:    f32,
}

RasterizationDesc :: struct {
	depthBias:             DepthBiasDesc,
	fillMode:              FillMode,
	cullMode:              CullMode,
	frontCounterClockwise: bool,
	depthClamp:            bool,
	lineSmoothing:         bool, // requires "features.lineSmoothing"
	conservativeRaster:    bool, // requires "tiers.conservativeRaster != 0"
	shadingRate:           bool, // requires "tiers.shadingRate != 0", expects "CmdSetShadingRate" and optionally "AttachmentsDesc::shadingRate"
}

MultisampleDesc :: struct {
	sampleMask:      u32, // can be "ALL"
	sampleNum:       Sample_t,
	alphaToCoverage: bool,
	sampleLocations: bool, // requires "tiers.sampleLocations != 0", expects "CmdSetSampleLocations"
}

ShadingRateDesc :: struct {
	shadingRate:        ShadingRate,
	primitiveCombiner:  ShadingRateCombiner, // requires "tiers.sampleLocations >= 2"
	attachmentCombiner: ShadingRateCombiner, // requires "tiers.sampleLocations >= 2"
}

//============================================================================================================================================================================================
Multiview :: enum u8 {
	//============================================================================================================================================================================================
	FLEXIBLE       = 0,

	//============================================================================================================================================================================================
	LAYER_BASED    = 1,

	//============================================================================================================================================================================================
	VIEWPORT_BASED = 2,

	//============================================================================================================================================================================================
	MAX_NUM        = 3,
}

// https://registry.khronos.org/vulkan/specs/latest/man/html/VkLogicOp.html
// https://learn.microsoft.com/en-us/windows/win32/api/d3d12/ne-d3d12-d3d12_logic_op
// S - source color 0
// D - destination color
LogicOp :: enum u8 {
	// S - source color 0
	// D - destination color
	NONE          = 0,

	// S - source color 0
	// D - destination color
	CLEAR         = 1,

	// S - source color 0
	// D - destination color
	AND           = 2,

	// S - source color 0
	// D - destination color
	AND_REVERSE   = 3,

	// S - source color 0
	// D - destination color
	COPY          = 4,

	// S - source color 0
	// D - destination color
	AND_INVERTED  = 5,

	// S - source color 0
	// D - destination color
	XOR           = 6,

	// S - source color 0
	// D - destination color
	OR            = 7,

	// S - source color 0
	// D - destination color
	NOR           = 8,

	// S - source color 0
	// D - destination color
	EQUIVALENT    = 9,

	// S - source color 0
	// D - destination color
	INVERT        = 10,

	// S - source color 0
	// D - destination color
	OR_REVERSE    = 11,

	// S - source color 0
	// D - destination color
	COPY_INVERTED = 12,

	// S - source color 0
	// D - destination color
	OR_INVERTED   = 13,

	// S - source color 0
	// D - destination color
	NAND          = 14,

	// S - source color 0
	// D - destination color
	SET           = 15,

	// S - source color 0
	// D - destination color
	MAX_NUM       = 16,
}

// https://registry.khronos.org/vulkan/specs/latest/man/html/VkStencilOp.html
// https://learn.microsoft.com/en-us/windows/win32/api/d3d12/ne-d3d12-d3d12_stencil_op
// R - reference, set by "CmdSetStencilReference"
// D - stencil buffer
StencilOp :: enum u8 {
	// R - reference, set by "CmdSetStencilReference"
	// D - stencil buffer
	KEEP                = 0,

	// R - reference, set by "CmdSetStencilReference"
	// D - stencil buffer
	ZERO                = 1,

	// R - reference, set by "CmdSetStencilReference"
	// D - stencil buffer
	REPLACE             = 2,

	// R - reference, set by "CmdSetStencilReference"
	// D - stencil buffer
	INCREMENT_AND_CLAMP = 3,

	// R - reference, set by "CmdSetStencilReference"
	// D - stencil buffer
	DECREMENT_AND_CLAMP = 4,

	// R - reference, set by "CmdSetStencilReference"
	// D - stencil buffer
	INVERT              = 5,

	// R - reference, set by "CmdSetStencilReference"
	// D - stencil buffer
	INCREMENT_AND_WRAP  = 6,

	// R - reference, set by "CmdSetStencilReference"
	// D - stencil buffer
	DECREMENT_AND_WRAP  = 7,

	// R - reference, set by "CmdSetStencilReference"
	// D - stencil buffer
	MAX_NUM             = 8,
}

// https://registry.khronos.org/vulkan/specs/latest/man/html/VkBlendFactor.html
// https://learn.microsoft.com/en-us/windows/win32/api/d3d12/ne-d3d12-d3d12_blend
// S0 - source color 0
// S1 - source color 1
// D - destination color
// C - blend constants, set by "CmdSetBlendConstants"
BlendFactor :: enum u8 {
	// S0 - source color 0
	// S1 - source color 1
	// D - destination color
	// C - blend constants, set by "CmdSetBlendConstants"
	ZERO                     = 0, // RGB                               ALPHA

	// S0 - source color 0
	// S1 - source color 1
	// D - destination color
	// C - blend constants, set by "CmdSetBlendConstants"
	ONE                      = 1, // RGB                               ALPHA

	// S0 - source color 0
	// S1 - source color 1
	// D - destination color
	// C - blend constants, set by "CmdSetBlendConstants"
	SRC_COLOR                = 2, // RGB                               ALPHA

	// S0 - source color 0
	// S1 - source color 1
	// D - destination color
	// C - blend constants, set by "CmdSetBlendConstants"
	ONE_MINUS_SRC_COLOR      = 3, // RGB                               ALPHA

	// S0 - source color 0
	// S1 - source color 1
	// D - destination color
	// C - blend constants, set by "CmdSetBlendConstants"
	DST_COLOR                = 4, // RGB                               ALPHA

	// S0 - source color 0
	// S1 - source color 1
	// D - destination color
	// C - blend constants, set by "CmdSetBlendConstants"
	ONE_MINUS_DST_COLOR      = 5, // RGB                               ALPHA

	// S0 - source color 0
	// S1 - source color 1
	// D - destination color
	// C - blend constants, set by "CmdSetBlendConstants"
	SRC_ALPHA                = 6, // RGB                               ALPHA

	// S0 - source color 0
	// S1 - source color 1
	// D - destination color
	// C - blend constants, set by "CmdSetBlendConstants"
	ONE_MINUS_SRC_ALPHA      = 7, // RGB                               ALPHA

	// S0 - source color 0
	// S1 - source color 1
	// D - destination color
	// C - blend constants, set by "CmdSetBlendConstants"
	DST_ALPHA                = 8, // RGB                               ALPHA

	// S0 - source color 0
	// S1 - source color 1
	// D - destination color
	// C - blend constants, set by "CmdSetBlendConstants"
	ONE_MINUS_DST_ALPHA      = 9, // RGB                               ALPHA

	// S0 - source color 0
	// S1 - source color 1
	// D - destination color
	// C - blend constants, set by "CmdSetBlendConstants"
	CONSTANT_COLOR           = 10, // RGB                               ALPHA

	// S0 - source color 0
	// S1 - source color 1
	// D - destination color
	// C - blend constants, set by "CmdSetBlendConstants"
	ONE_MINUS_CONSTANT_COLOR = 11, // RGB                               ALPHA

	// S0 - source color 0
	// S1 - source color 1
	// D - destination color
	// C - blend constants, set by "CmdSetBlendConstants"
	CONSTANT_ALPHA           = 12, // RGB                               ALPHA

	// S0 - source color 0
	// S1 - source color 1
	// D - destination color
	// C - blend constants, set by "CmdSetBlendConstants"
	ONE_MINUS_CONSTANT_ALPHA = 13, // RGB                               ALPHA

	// S0 - source color 0
	// S1 - source color 1
	// D - destination color
	// C - blend constants, set by "CmdSetBlendConstants"
	SRC_ALPHA_SATURATE       = 14, // RGB                               ALPHA

	// S0 - source color 0
	// S1 - source color 1
	// D - destination color
	// C - blend constants, set by "CmdSetBlendConstants"
	SRC1_COLOR               = 15, // RGB                               ALPHA

	// S0 - source color 0
	// S1 - source color 1
	// D - destination color
	// C - blend constants, set by "CmdSetBlendConstants"
	ONE_MINUS_SRC1_COLOR     = 16, // RGB                               ALPHA

	// S0 - source color 0
	// S1 - source color 1
	// D - destination color
	// C - blend constants, set by "CmdSetBlendConstants"
	SRC1_ALPHA               = 17, // RGB                               ALPHA

	// S0 - source color 0
	// S1 - source color 1
	// D - destination color
	// C - blend constants, set by "CmdSetBlendConstants"
	ONE_MINUS_SRC1_ALPHA     = 18, // RGB                               ALPHA

	// S0 - source color 0
	// S1 - source color 1
	// D - destination color
	// C - blend constants, set by "CmdSetBlendConstants"
	MAX_NUM                  = 19, // RGB                               ALPHA
} // RGB                               ALPHA

// https://registry.khronos.org/vulkan/specs/latest/man/html/VkBlendOp.html
// https://learn.microsoft.com/en-us/windows/win32/api/d3d12/ne-d3d12-d3d12_blend_op
// S - source color
// D - destination color
// Sf - source factor, produced by "BlendFactor"
// Df - destination factor, produced by "BlendFactor"
BlendOp :: enum u8 {
	// S - source color
	// D - destination color
	// Sf - source factor, produced by "BlendFactor"
	// Df - destination factor, produced by "BlendFactor"
	ADD              = 0,

	// S - source color
	// D - destination color
	// Sf - source factor, produced by "BlendFactor"
	// Df - destination factor, produced by "BlendFactor"
	SUBTRACT         = 1,

	// S - source color
	// D - destination color
	// Sf - source factor, produced by "BlendFactor"
	// Df - destination factor, produced by "BlendFactor"
	REVERSE_SUBTRACT = 2,

	// S - source color
	// D - destination color
	// Sf - source factor, produced by "BlendFactor"
	// Df - destination factor, produced by "BlendFactor"
	MIN              = 3,

	// S - source color
	// D - destination color
	// Sf - source factor, produced by "BlendFactor"
	// Df - destination factor, produced by "BlendFactor"
	MAX              = 4,

	// S - source color
	// D - destination color
	// Sf - source factor, produced by "BlendFactor"
	// Df - destination factor, produced by "BlendFactor"
	MAX_NUM          = 5,
}

// https://registry.khronos.org/vulkan/specs/latest/man/html/VkColorComponentFlagBits.html
ColorWriteBits :: enum u8 {
	NONE = 0,
	R    = 1,
	G    = 2,
	B    = 4,
	A    = 8,
	RGB  = 7,
	RGBA = 15,
}

// https://registry.khronos.org/vulkan/specs/latest/man/html/VkStencilOpState.html
// https://learn.microsoft.com/en-us/windows/win32/api/d3d12/ns-d3d12-d3d12_depth_stencil_desc
StencilDesc :: struct {
	compareOp:   CompareOp, // "compareOp != NONE", expects "CmdSetStencilReference"
	failOp:      StencilOp,
	passOp:      StencilOp,
	depthFailOp: StencilOp,
	writeMask:   u8,
	compareMask: u8,
}

// https://registry.khronos.org/vulkan/specs/latest/man/html/VkPipelineDepthStencilStateCreateInfo.html
DepthAttachmentDesc :: struct {
	compareOp:  CompareOp,
	write:      bool,
	boundsTest: bool, // requires "features.depthBoundsTest", expects "CmdSetDepthBounds"
}

StencilAttachmentDesc :: struct {
	front: StencilDesc,
	back:  StencilDesc, // requires "features.independentFrontAndBackStencilReferenceAndMasks" for "back.writeMask"
}

// https://registry.khronos.org/vulkan/specs/latest/man/html/VkPipelineColorBlendAttachmentState.html
// https://learn.microsoft.com/en-us/windows/win32/api/d3d12/ns-d3d12-d3d12_render_target_blend_desc
BlendDesc :: struct {
	srcFactor: BlendFactor,
	dstFactor: BlendFactor,
	op:        BlendOp,
}

ColorAttachmentDesc :: struct {
	format:         Format,
	colorBlend:     BlendDesc,
	alphaBlend:     BlendDesc,
	colorWriteMask: ColorWriteBits,
	blendEnabled:   bool,
}

OutputMergerDesc :: struct {
	colors:             ^ColorAttachmentDesc,
	colorNum:           u32,
	depth:              DepthAttachmentDesc,
	stencil:            StencilAttachmentDesc,
	depthStencilFormat: Format,
	logicOp:            LogicOp, // requires "features.logicOp"
	viewMask:           u32, // if non-0, requires "viewMaxNum > 1"
	multiview:          Multiview, // if "viewMask != 0", requires "features.(xxx)Multiview"
}

AttachmentsDesc :: struct {
	depthStencil: ^Descriptor,
	shadingRate:  ^Descriptor, // requires "tiers.shadingRate >= 2"
	colors:       ^^Descriptor,
	colorNum:     u32,
	viewMask:     u32, // if non-0, requires "viewMaxNum > 1"
}

// https://docs.vulkan.org/guide/latest/robustness.html
Robustness :: enum u8 {
	DEFAULT = 0,
	OFF     = 1,
	VK      = 2,
	D3D12   = 3,
	MAX_NUM = 4,
}

// It's recommended to use "NRI.hlsl" in the shader code
ShaderDesc :: struct {
	stage:          StageBits,
	bytecode:       rawptr,
	size:           u64,
	entryPointName: cstring,
}

GraphicsPipelineDesc :: struct {
	pipelineLayout: ^PipelineLayout,
	vertexInput:    ^VertexInputDesc,
	inputAssembly:  InputAssemblyDesc,
	rasterization:  RasterizationDesc,
	multisample:    ^MultisampleDesc,
	outputMerger:   OutputMergerDesc,
	shaders:        ^ShaderDesc,
	shaderNum:      u32,
	robustness:     Robustness,
}

ComputePipelineDesc :: struct {
	pipelineLayout: ^PipelineLayout,
	shader:         ShaderDesc,
	robustness:     Robustness,
}

// https://microsoft.github.io/DirectX-Specs/d3d/CountersAndQueries.html
// https://registry.khronos.org/vulkan/specs/latest/man/html/VkQueryType.html
QueryType :: enum u8 {
	TIMESTAMP                             = 0,
	TIMESTAMP_COPY_QUEUE                  = 1,
	OCCLUSION                             = 2,
	PIPELINE_STATISTICS                   = 3,
	ACCELERATION_STRUCTURE_SIZE           = 4,
	ACCELERATION_STRUCTURE_COMPACTED_SIZE = 5,
	MICROMAP_COMPACTED_SIZE               = 6,
	MAX_NUM                               = 7,
}

QueryPoolDesc :: struct {
	queryType: QueryType,
	capacity:  u32,
}

// Data layout for QueryType::PIPELINE_STATISTICS
// https://registry.khronos.org/vulkan/specs/latest/man/html/VkQueryPipelineStatisticFlagBits.html
// https://learn.microsoft.com/en-us/windows/win32/api/d3d12/ns-d3d12-d3d12_query_data_pipeline_statistics
PipelineStatisticsDesc :: struct {
	// Common part
	inputVertexNum:                    u64,
	inputPrimitiveNum:                 u64,
	vertexShaderInvocationNum:         u64,
	geometryShaderInvocationNum:       u64,
	geometryShaderPrimitiveNum:        u64,
	rasterizerInPrimitiveNum:          u64,
	rasterizerOutPrimitiveNum:         u64,
	fragmentShaderInvocationNum:       u64,
	tessControlShaderInvocationNum:    u64,
	tessEvaluationShaderInvocationNum: u64,
	computeShaderInvocationNum:        u64,

	// If "features.meshShaderPipelineStats"
	meshControlShaderInvocationNum:    u64,
	meshEvaluationShaderInvocationNum: u64,

	// D3D12: if "features.meshShaderPipelineStats"
	meshEvaluationShaderPrimitiveNum:  u64,
}

// Command signatures (default)
DrawDesc :: struct {
	vertexNum:    u32,
	instanceNum:  u32,
	baseVertex:   u32, // vertex buffer offset = CmdSetVertexBuffers.offset + baseVertex * VertexStreamDesc::stride
	baseInstance: u32,
} // see NRI_FILL_DRAW_COMMAND

DrawIndexedDesc :: struct {
	indexNum:     u32,
	instanceNum:  u32,
	baseIndex:    u32, // index buffer offset = CmdSetIndexBuffer.offset + baseIndex * sizeof(CmdSetIndexBuffer.indexType)
	baseVertex:   i32, // index += baseVertex
	baseInstance: u32,
} // see NRI_FILL_DRAW_INDEXED_COMMAND

DispatchDesc :: struct {
	x, y, z: u32,
}

// D3D12: modified draw command signatures, if the bound pipeline layout has "PipelineLayoutBits::ENABLE_D3D12_DRAW_PARAMETERS_EMULATION"
//  - the following structs must be used instead
// - "NRI_ENABLE_DRAW_PARAMETERS_EMULATION" must be defined prior inclusion of "NRI.hlsl"
DrawBaseDesc :: struct {
	shaderEmulatedBaseVertex:   u32, // root constant
	shaderEmulatedBaseInstance: u32, // root constant
	vertexNum:                  u32,
	instanceNum:                u32,
	baseVertex:                 u32, // vertex buffer offset = CmdSetVertexBuffers.offset + baseVertex * VertexStreamDesc::stride
	baseInstance:               u32,
} // see NRI_FILL_DRAW_COMMAND

DrawIndexedBaseDesc :: struct {
	shaderEmulatedBaseVertex:   i32, // root constant
	shaderEmulatedBaseInstance: u32, // root constant
	indexNum:                   u32,
	instanceNum:                u32,
	baseIndex:                  u32, // index buffer offset = CmdSetIndexBuffer.offset + baseIndex * sizeof(CmdSetIndexBuffer.indexType)
	baseVertex:                 i32, // index += baseVertex
	baseInstance:               u32,
} // see NRI_FILL_DRAW_INDEXED_COMMAND

// Copy
TextureRegionDesc :: struct {
	x:           Dim_t,
	y:           Dim_t,
	z:           Dim_t,
	width:       Dim_t, // can be "WHOLE_SIZE" (mip)
	height:      Dim_t, // can be "WHOLE_SIZE" (mip)
	depth:       Dim_t, // can be "WHOLE_SIZE" (mip)
	mipOffset:   Dim_t,
	layerOffset: Dim_t,
	planes:      PlaneBits,
}

TextureDataLayoutDesc :: struct {
	offset:     u64, // a buffer offset must be a multiple of "uploadBufferTextureSliceAlignment" (data placement alignment)
	rowPitch:   u32, // must be a multiple of "uploadBufferTextureRowAlignment"
	slicePitch: u32, // must be a multiple of "uploadBufferTextureSliceAlignment"
}

// Work submission
FenceSubmitDesc :: struct {
	fence:  ^Fence,
	value:  u64,
	stages: StageBits,
}

QueueSubmitDesc :: struct {
	waitFences:       ^FenceSubmitDesc,
	waitFenceNum:     u32,
	commandBuffers:   ^^CommandBuffer,
	commandBufferNum: u32,
	signalFences:     ^FenceSubmitDesc,
	signalFenceNum:   u32,
	swapChain:        ^SwapChain, // required if "NRILowLatency" is enabled in the swap chain
}

// Clear
ClearDesc :: struct {
	value:                ClearValue,
	planes:               PlaneBits,
	colorAttachmentIndex: u32,
}

// Required synchronization
// - variant 1: "SHADER_RESOURCE_STORAGE" access ("SHADER_RESOURCE_STORAGE" layout) and "CLEAR_STORAGE" stage + any shader stage (or "ALL")
// - variant 2: "CLEAR_STORAGE" access ("SHADER_RESOURCE_STORAGE" layout) and "CLEAR_STORAGE" stage
ClearStorageDesc :: struct {
	// For any buffers and textures with integer formats:
	//  - Clears a storage view with bit-precise values, copying the lower "N" bits from "value.[f/ui/i].channel"
	//    to the corresponding channel, where "N" is the number of bits in the "channel" of the resource format
	// For textures with non-integer formats:
	//  - Clears a storage view with float values with format conversion from "FLOAT" to "UNORM/SNORM" where appropriate
	// For buffers:
	//  - To avoid discrepancies in behavior between GAPIs use "R32f/ui/i" formats for views
	//  - D3D: structured buffers are unsupported!
	storage:         ^Descriptor, // a "STORAGE" descriptor
	value:           Color, // avoid overflow
	setIndex:        u32,
	rangeIndex:      u32,
	descriptorIndex: u32,
}

//============================================================================================================================================================================================
Vendor :: enum u8 {
	//============================================================================================================================================================================================
	UNKNOWN = 0,

	//============================================================================================================================================================================================
	NVIDIA  = 1,

	//============================================================================================================================================================================================
	AMD     = 2,

	//============================================================================================================================================================================================
	INTEL   = 3,

	//============================================================================================================================================================================================
	MAX_NUM = 4,
}

// https://registry.khronos.org/vulkan/specs/latest/man/html/VkPhysicalDeviceType.html
Architecture :: enum u8 {
	UNKNOWN    = 0,
	INTEGRATED = 1,
	DESCRETE   = 2,
	MAX_NUM    = 3,
}

// https://registry.khronos.org/vulkan/specs/latest/man/html/VkQueueFlagBits.html
// https://learn.microsoft.com/en-us/windows/win32/api/d3d12/ne-d3d12-d3d12_command_list_type
QueueType :: enum u8 {
	GRAPHICS = 0,
	COMPUTE  = 1,
	COPY     = 2,
	MAX_NUM  = 3,
}

AdapterDesc :: struct {
	name:                   [256]u8,
	uid:                    Uid_t, // "LUID" (preferred) if "uid.high = 0", or "UUID" otherwise
	videoMemorySize:        u64,
	sharedSystemMemorySize: u64,
	deviceId:               u32,
	queueNum:               [3]u32,
	vendor:                 Vendor,
	architecture:           Architecture,
}

// Feature support coverage: https://vulkan.gpuinfo.org/ and https://d3d12infodb.boolka.dev/
DeviceDesc :: struct {
	// Common
	adapterDesc:     AdapterDesc, // "queueNum" reflects available number of queues per "QueueType"
	graphicsAPI:     GraphicsAPI,
	nriVersion:      u16,
	shaderModel:     u8, // major * 10 + minor
	viewport:        struct {
		maxNum:    u32,
		boundsMin: i16,
		boundsMax: i16,
	},
	dimensions:      struct {
		typedBufferMaxDim:     u32,
		attachmentMaxDim:      Dim_t,
		attachmentLayerMaxNum: Dim_t,
		texture1DMaxDim:       Dim_t,
		texture2DMaxDim:       Dim_t,
		texture3DMaxDim:       Dim_t,
		textureLayerMaxNum:    Dim_t,
	},
	precision:       struct {
		viewportBits: u32,
		subPixelBits: u32,
		subTexelBits: u32,
		mipmapBits:   u32,
	},
	memory:          struct {
		deviceUploadHeapSize:     u64, // ReBAR
		bufferMaxSize:            u64,
		allocationMaxSize:        u64,
		allocationMaxNum:         u32,
		samplerAllocationMaxNum:  u32,
		constantBufferMaxRange:   u32,
		storageBufferMaxRange:    u32,
		bufferTextureGranularity: u32, // specifies a page-like granularity at which linear and non-linear resources must be placed in adjacent memory locations to avoid aliasing
		alignmentDefault:         u32, // (INTERNAL) worst-case alignment for a memory allocation respecting all possible placed resources, excluding multisample textures
		alignmentMultisample:     u32, // (INTERNAL) worst-case alignment for a memory allocation respecting all possible placed resources, including multisample textures
	},
	memoryAlignment: struct {
		uploadBufferTextureRow:      u32,
		uploadBufferTextureSlice:    u32,
		bufferShaderResourceOffset:  u32,
		constantBufferOffset:        u32,
		scratchBufferOffset:         u32,
		shaderBindingTable:          u32,
		accelerationStructureOffset: u32,
		micromapOffset:              u32,
	},
	pipelineLayout:  struct {
		descriptorSetMaxNum:  u32,
		rootConstantMaxSize:  u32,
		rootDescriptorMaxNum: u32,
	},
	descriptorSet:   struct {
		samplerMaxNum:        u32,
		constantBufferMaxNum: u32,
		storageBufferMaxNum:  u32,
		textureMaxNum:        u32,
		storageTextureMaxNum: u32,
		updateAfterSet:       struct {
			samplerMaxNum:        u32,
			constantBufferMaxNum: u32,
			storageBufferMaxNum:  u32,
			textureMaxNum:        u32,
			storageTextureMaxNum: u32,
		},
	},
	shaderStage:     struct {
		// Per stage resources
		descriptorSamplerMaxNum:        u32,
		descriptorConstantBufferMaxNum: u32,
		descriptorStorageBufferMaxNum:  u32,
		descriptorTextureMaxNum:        u32,
		descriptorStorageTextureMaxNum: u32,
		resourceMaxNum:                 u32,
		updateAfterSet:                 struct {
			descriptorSamplerMaxNum:        u32,
			descriptorConstantBufferMaxNum: u32,
			descriptorStorageBufferMaxNum:  u32,
			descriptorTextureMaxNum:        u32,
			descriptorStorageTextureMaxNum: u32,
			resourceMaxNum:                 u32,
		},
		vertex:                         struct {
			attributeMaxNum:       u32,
			streamMaxNum:          u32,
			outputComponentMaxNum: u32,
		},
		tesselationControl:             struct {
			generationMaxLevel:             f32,
			patchPointMaxNum:               u32,
			perVertexInputComponentMaxNum:  u32,
			perVertexOutputComponentMaxNum: u32,
			perPatchOutputComponentMaxNum:  u32,
			totalOutputComponentMaxNum:     u32,
		},
		tesselationEvaluation:          struct {
			inputComponentMaxNum:  u32,
			outputComponentMaxNum: u32,
		},
		geometry:                       struct {
			invocationMaxNum:           u32,
			inputComponentMaxNum:       u32,
			outputComponentMaxNum:      u32,
			outputVertexMaxNum:         u32,
			totalOutputComponentMaxNum: u32,
		},
		fragment:                       struct {
			inputComponentMaxNum:       u32,
			attachmentMaxNum:           u32,
			dualSourceAttachmentMaxNum: u32,
		},
		compute:                        struct {
			workGroupMaxNum:           [3]u32,
			workGroupMaxDim:           [3]u32,
			workGroupInvocationMaxNum: u32,
			sharedMemoryMaxSize:       u32,
		},
		rayTracing:                     struct {
			shaderGroupIdentifierSize: u32,
			tableMaxStride:            u32,
			recursionMaxDepth:         u32,
		},
		meshControl:                    struct {
			sharedMemoryMaxSize:       u32,
			workGroupInvocationMaxNum: u32,
			payloadMaxSize:            u32,
		},
		meshEvaluation:                 struct {
			outputVerticesMaxNum:      u32,
			outputPrimitiveMaxNum:     u32,
			outputComponentMaxNum:     u32,
			sharedMemoryMaxSize:       u32,
			workGroupInvocationMaxNum: u32,
		},
	},
	wave:            struct {
		laneMinNum:          u32,
		laneMaxNum:          u32,
		waveOpsStages:       StageBits, // SM 6.0+ (see "shaderFeatures.waveX")
		quadOpsStages:       StageBits, // SM 6.0+ (see "shaderFeatures.waveQuad")
		derivativeOpsStages: StageBits, // SM 6.6+ (https://microsoft.github.io/DirectX-Specs/d3d/HLSL_SM_6_6_Derivatives.html#derivative-functions)
	},
	other:           struct {
		timestampFrequencyHz:              u64,
		micromapSubdivisionMaxLevel:       u32,
		drawIndirectMaxNum:                u32,
		samplerLodBiasMax:                 f32,
		samplerAnisotropyMax:              f32,
		texelGatherOffsetMin:              i8,
		texelOffsetMin:                    i8,
		texelOffsetMax:                    u8,
		texelGatherOffsetMax:              u8,
		clipDistanceMaxNum:                u8,
		cullDistanceMaxNum:                u8,
		combinedClipAndCullDistanceMaxNum: u8,
		viewMaxNum:                        u8, // multiview is supported if > 1
		shadingRateAttachmentTileSize:     u8, // square size
	},
	tiers:           struct {
		// 1 - 1/2 pixel uncertainty region and does not support post-snap degenerates
		// 2 - reduces the maximum uncertainty region to 1/256 and requires post-snap degenerates not be culled
		// 3 - maintains a maximum 1/256 uncertainty region and adds support for inner input coverage, aka "SV_InnerCoverage"
		conservativeRaster: u8,

		// 1 - a single sample pattern can be specified to repeat for every pixel ("locationNum / sampleNum" ratio must be 1 in "CmdSetSampleLocations"),
		//     1x and 16x sample counts do not support programmable locations
		// 2 - four separate sample patterns can be specified for each pixel in a 2x2 grid ("locationNum / sampleNum" ratio can be 1 or 4 in "CmdSetSampleLocations"),
		//     all sample counts support programmable positions
		sampleLocations:    u8,

		// 1 - DXR 1.0: full raytracing functionality, except features below
		// 2 - DXR 1.1: adds - ray query, "CmdDispatchRaysIndirect", "GeometryIndex()" intrinsic, additional ray flags & vertex formats
		// 3 - DXR 1.2: adds - micromap, shader execution reordering
		rayTracing:         u8,

		// 1 - shading rate can be specified only per draw
		// 2 - adds: per primitive shading rate, per "shadingRateAttachmentTileSize" shading rate, combiners, "SV_ShadingRate" support
		shadingRate:        u8,

		// 0 - ALL descriptors in range must be valid by the time the command list executes
		// 1 - only "CONSTANT_BUFFER" and "STORAGE" descriptors in range must be valid
		// 2 - only referenced descriptors must be valid
		resourceBinding:    u8,
		bindless:           u8,

		// 1 - a "Memory" can support resources from all 3 categories: buffers, attachments, all other textures
		memory:             u8,
	},
	features:        struct {
		// Bigger
		getMemoryDesc2:                                  u32, // "GetXxxMemoryDesc2" support (VK: requires "maintenance4", D3D: supported)
		enhancedBarriers:                                u32, // VK: supported, D3D12: requires "AgilitySDK", D3D11: unsupported
		swapChain:                                       u32, // NRISwapChain
		rayTracing:                                      u32, // NRIRayTracing
		meshShader:                                      u32, // NRIMeshShader
		lowLatency:                                      u32, // NRILowLatency
		micromap:                                        u32, // see "Micromap"

		// Smaller
		independentFrontAndBackStencilReferenceAndMasks: u32, // see "StencilAttachmentDesc::back"
		textureFilterMinMax:                             u32, // see "ReductionMode"
		logicOp:                                         u32, // see "LogicOp"
		depthBoundsTest:                                 u32, // see "DepthAttachmentDesc::boundsTest"
		drawIndirectCount:                               u32, // see "countBuffer" and "countBufferOffset"
		lineSmoothing:                                   u32, // see "RasterizationDesc::lineSmoothing"
		copyQueueTimestamp:                              u32, // see "QueryType::TIMESTAMP_COPY_QUEUE"
		meshShaderPipelineStats:                         u32, // see "PipelineStatisticsDesc"
		dynamicDepthBias:                                u32, // see "CmdSetDepthBias"
		additionalShadingRates:                          u32, // see "ShadingRate"
		viewportOriginBottomLeft:                        u32, // see "Viewport"
		regionResolve:                                   u32, // see "CmdResolveTexture"
		flexibleMultiview:                               u32, // see "Multiview::FLEXIBLE"
		layerBasedMultiview:                             u32, // see "Multiview::LAYRED_BASED"
		viewportBasedMultiview:                          u32, // see "Multiview::VIEWPORT_BASED"
		presentFromCompute:                              u32, // see "SwapChainDesc::queue"
		waitableSwapChain:                               u32, // see "SwapChainDesc::waitable"
		resizableSwapChain:                              u32, // swap chain can be resized without triggering an "OUT_OF_DATE" error
		pipelineStatistics:                              u32, // see "QueryType::PIPELINE_STATISTICS"
		rootConstantsOffset:                             u32, // see "SetRootConstantsDesc" (unsupported only in D3D11)
		nonConstantBufferRootDescriptorOffset:           u32, // see "SetRootDescriptorDesc" (unsupported only in D3D11)
		mutableDescriptorType:                           u32, // see "DescriptorRangeBits::MUTABLE"
	},
	shaderFeatures:  struct {
		viewportIndex:             u32, // SV_ViewportArrayIndex, always can be used in geometry shaders
		layerIndex:                u32, // SV_RenderTargetArrayIndex, always can be used in geometry shaders
		unnormalizedCoordinates:   u32, // https://microsoft.github.io/DirectX-Specs/d3d/VulkanOn12.html#non-normalized-texture-sampling-coordinates
		clock:                     u32, // https://github.com/Microsoft/DirectXShaderCompiler/blob/main/docs/SPIR-V.rst#readclock
		rasterizedOrderedView:     u32, // https://microsoft.github.io/DirectX-Specs/d3d/RasterOrderViews.html (aka fragment shader interlock)
		barycentric:               u32, // https://github.com/microsoft/DirectXShaderCompiler/wiki/SV_Barycentrics
		rayTracingPositionFetch:   u32, // https://docs.vulkan.org/features/latest/features/proposals/VK_KHR_ray_tracing_position_fetch.html

		// I32 and F32 are always supported
		nativeI16:                 u32, // "(u)int16_t"
		nativeF16:                 u32, // "float16_t"
		nativeI64:                 u32, // "(u)int64_t"
		nativeF64:                 u32, // "double"

		// I32 atomics are always supported (for others it can be partial support of SMEM, texture or buffer atomics)
		atomicsI16:                u32, // "(u)int16_t" atomics
		atomicsF16:                u32, // "float16_t" atomics
		atomicsF32:                u32, // "float" atomics
		atomicsI64:                u32, // "(u)int64_t" atomics
		atomicsF64:                u32, // "double" atomics
		storageReadWithoutFormat:  u32, // NRI_FORMAT("unknown") is allowed for storage reads
		storageWriteWithoutFormat: u32, // NRI_FORMAT("unknown") is allowed for storage writes
		waveQuery:                 u32, // WaveIsFirstLane, WaveGetLaneCount, WaveGetLaneIndex
		waveVote:                  u32, // WaveActiveAllTrue, WaveActiveAnyTrue, WaveActiveAllEqual
		waveShuffle:               u32, // WaveReadLaneFirst, WaveReadLaneAt
		waveArithmetic:            u32, // WaveActiveSum, WaveActiveProduct, WaveActiveMin, WaveActiveMax, WavePrefixProduct, WavePrefixSum
		waveReduction:             u32, // WaveActiveCountBits, WaveActiveBitAnd, WaveActiveBitOr, WaveActiveBitXor, WavePrefixCountBits
		waveQuad:                  u32, // QuadReadLaneAt, QuadReadAcrossX, QuadReadAcrossY, QuadReadAcrossDiagonal
	},
}
