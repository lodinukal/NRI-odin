package en_gpu

Fence :: distinct rawptr
Memory :: distinct rawptr
Buffer :: distinct rawptr
Device :: distinct rawptr
Texture :: distinct rawptr
Pipeline :: distinct rawptr
Query_Pool :: distinct rawptr
Descriptor :: distinct rawptr
Command_Queue :: distinct rawptr
Command_Buffer :: distinct rawptr
Descriptor_Set :: distinct rawptr
Descriptor_Pool :: distinct rawptr
Pipeline_Layout :: distinct rawptr
Command_Allocator :: distinct rawptr

mip :: u8
sample :: u8
dim :: u16
memory_type :: u32

ALL_SAMPLES: u32 : 0
ONE_VIEWPORT: u32 : 0
WHOLE_SIZE: u32 : 0
REMAINING_MIPS: u32 : 0
REMAINING_LAYERS: u32 : 0

Graphics_API :: enum u8 {
	None,
	D3D11,
	D3D12,
	Vulkan,
}

Result :: enum u8 {
	Success,
	Failure,
	Invalid_Parameter,
	Out_Of_Memory,
	Unsupported,
	Device_Lost,
	Out_Of_Date,
}

Format :: enum u8 {
	UNKNOWN,
	R8_UNORM,
	R8_SNORM,
	R8_UINT,
	R8_SINT,
	RG8_UNORM,
	RG8_SNORM,
	RG8_UINT,
	RG8_SINT,
	BGRA8_UNORM,
	BGRA8_SRGB,
	RGBA8_UNORM,
	RGBA8_SRGB,
	RGBA8_SNORM,
	RGBA8_UINT,
	RGBA8_SINT,
	R16_UNORM,
	R16_SNORM,
	R16_UINT,
	R16_SINT,
	R16_SFLOAT,
	RG16_UNORM,
	RG16_SNORM,
	RG16_UINT,
	RG16_SINT,
	RG16_SFLOAT,
	RGBA16_UNORM,
	RGBA16_SNORM,
	RGBA16_UINT,
	RGBA16_SINT,
	RGBA16_SFLOAT,
	R32_UINT,
	R32_SINT,
	R32_SFLOAT,
	RG32_UINT,
	RG32_SINT,
	RG32_SFLOAT,
	RGB32_UINT,
	RGB32_SINT,
	RGB32_SFLOAT,
	RGBA32_UINT,
	RGBA32_SINT,
	RGBA32_SFLOAT,
	B5_G6_R5_UNORM,
	B5_G5_R5_A1_UNORM,
	B4_G4_R4_A4_UNORM,
	R10_G10_B10_A2_UNORM,
	R10_G10_B10_A2_UINT,
	R11_G11_B10_UFLOAT,
	R9_G9_B9_E5_UFLOAT,
	BC1_RGBA_UNORM,
	BC1_RGBA_SRGB,
	BC2_RGBA_UNORM,
	BC2_RGBA_SRGB,
	BC3_RGBA_UNORM,
	BC3_RGBA_SRGB,
	BC4_R_UNORM,
	BC4_R_SNORM,
	BC5_RG_UNORM,
	BC5_RG_SNORM,
	BC6H_RGB_UFLOAT,
	BC6H_RGB_SFLOAT,
	BC7_RGBA_UNORM,
	BC7_RGBA_SRGB,
	D16_UNORM,
	D24_UNORM_S8_UINT,
	D32_SFLOAT,
	D32_SFLOAT_S8_UINT_X24,
	R24_UNORM_X8,
	X24_G8_UINT,
	R32_SFLOAT_X8_X24,
	X32_G8_UINT_X24,
}

Plane_Bits :: enum u8 {
	Color,
	Depth,
	Stencil,
}
Plane_Flags :: bit_set[Plane_Bits;u32]
Plane_All: Plane_Flags : {.Color, .Depth, .Stencil}

Format_Support_Bits :: enum u8 {
	// Texture
	Texture,
	Storage_Texture,
	Color_Attachment,
	Depth_Stencil_Attachment,
	Blend,
	Storage_Texture_Atomics, // other than Load / Store

	// Buffer
	Buffer,
	Storage_Buffer,
	Vertex_Buffer,
	Storage_Buffer_Atomics, // other than Load / Store
}
Format_Support_Flags :: bit_set[Format_Support_Bits;u32]

Stage_Bits :: enum u8 {
	// Graphics
	Index_Input,
	Vertex_Shader,
	Tess_Control_Shader,
	Tess_Evaluation_Shader,
	Geometry_Shader,
	Mesh_Control_Shader,
	Mesh_Evaluation_Shader,
	Fragment_Shader,
	Depth_Stencil_Attachment,
	Color_Attachment,

	// Compute                                
	Compute_Shader,

	// Ray tracing
	Raygen_Shader,
	Miss_Shader,
	Intersection_Shader,
	Closest_Hit_Shader,
	Any_Hit_Shader,
	Callable_Shader,
	Acceleration_Structure,

	// Copy
	Copy,
	Clear_Storage,
	Resolve,

	// Modifiers
	Indirect,
}
Stage_Flags :: bit_set[Stage_Bits;u32]

Viewport :: struct {
	f, y, width, height, min_depth, max_depth: f32,
	origin_bottom_left:                        bool,
}

Rect :: struct {
	x, y:          i16,
	width, height: dim,
}

Colorf :: [4]f32
Colorui :: [4]u32
Colori :: [4]i32

Color :: struct #raw_union {
	f:  Colorf,
	ui: Colorui,
	i:  Colori,
}

Depth_Stencil :: struct {
	depth:   f32,
	stencil: u8,
}

Clear_Value :: struct #raw_union {
	color:         Color,
	depth_stencil: Depth_Stencil,
}

Sample_Location :: struct {
	x, y: i8,
}

Command_Queue_Type :: enum u8 {
	Graphics,
	Compute,
	Copy,
	High_Priority_Copy,
}

Memory_Location :: enum u8 {
	Device,
	Device_Upload, // soft fallback to HOST_UPLOAD
	Host_Upload,
	Host_Readback,
}

Texture_Type :: enum u8 {
	_1D,
	_2D,
	_3D,
}

Texture_1D_View_Type :: enum u8 {
	Shader_Resource,
	Shader_Resource_Array,
	Shader_Resource_Storage,
	Shader_Resource_Storage_Array,
	Color_Attachment,
	Depth_Stencil_Attachment,
	Depth_Readonly_Stencil_Attachment,
	Depth_Attachment_Stencil_Readonly,
	Depth_Stencil_Readonly,
}

Texture_2D_View_Type :: enum u8 {
	Shader_Resource,
	Shader_Resource_Array,
	Shader_Resource_Cube,
	Shader_Resource_Cube_Array,
	Shader_Resource_Storage,
	Shader_Resource_Storage_Array,
	Color_Attachment,
	Depth_Stencil_Attachment,
	Depth_Readonly_Stencil_Attachment,
	Depth_Attachment_Stencil_Readonly,
	Depth_Stencil_Readonly,
	Shading_Rate_Attachment,
}

Texture_3D_View_Type :: enum u8 {
	Shader_Resource,
	Shader_Resource_Storage,
	Color_Attachment,
}

Buffer_View_Type :: enum u8 {
	Shader_Resource,
	Shader_Resource_Storage,
	Constant,
}

Descriptor_Type :: enum u8 {
	Sampler,
	Constant_Buffer,
	Texture,
	Storage_Texture,
	Buffer,
	Storage_Buffer,
	Structured_Buffer,
	Storage_Structured_Buffer,
	Acceleration_Structure,
}

Texture_Usage_Bits :: enum u8 {
	Shader_Resource,
	Shader_Resource_Storage,
	Color_Attachment,
	Depth_Stencil_Attachment,
	Shading_Rate_Attachment,
}
Texture_Usage_Flags :: bit_set[Texture_Usage_Bits;u32]

Buffer_Usage_Bits :: enum u8 {
	Shader_Resource,
	Shader_Resource_Storage,
	Vertex_Buffer,
	Index_Buffer,
	Constant_Buffer,
	Argument_Buffer,
	Scratch_Buffer,
	Shader_Binding_Table,
	Acceleration_Structure_Build_Input,
	Acceleration_Structure_Storage,
}
Buffer_Usage_Flags :: bit_set[Buffer_Usage_Bits;u32]

Texture_Desc :: struct {
	type:       Texture_Type,
	usage:      Texture_Usage_Flags,
	format:     Format,
	width:      dim,
	height:     dim,
	depth:      dim,
	mip_num:    u8,
	layer_num:  u16,
	sample_num: u8,
}

Buffer_Desc :: struct {
	usage:            Buffer_Usage_Flags,
	size:             u64,
	structure_stride: u32,
}

Texture_1D_View_Desc :: struct {
	texture:      ^Texture,
	view_type:    Texture_1D_View_Type,
	format:       Format,
	mip_offset:   mip,
	mip_num:      mip,
	layer_offset: u16,
	layer_num:    u16,
}

Texture_2D_View_Desc :: struct {
	texture:      ^Texture,
	view_type:    Texture_2D_View_Type,
	format:       Format,
	mip_offset:   mip,
	mip_num:      mip,
	layer_offset: u16,
	layer_num:    u16,
}

Texture_3D_View_Desc :: struct {
	texture:      ^Texture,
	view_type:    Texture_3D_View_Type,
	format:       Format,
	mip_offset:   mip,
	mip_num:      mip,
	slice_offset: u16,
	slice_num:    u16,
}

Buffer_View_Desc :: struct {
	buffer:    ^Buffer,
	view_type: Buffer_View_Type,
	format:    Format,
	offset:    u64,
	size:      u64,
}

Descriptor_Pool_Desc :: struct {
	descriptor_set_max_num:            u32,
	sampler_max_num:                   u32,
	constant_buffer_max_num:           u32,
	dynamic_constant_buffer_max_num:   u32,
	texture_max_num:                   u32,
	storage_texture_max_num:           u32,
	buffer_max_num:                    u32,
	storage_buffer_max_num:            u32,
	structured_buffer_max_num:         u32,
	storage_structured_buffer_max_num: u32,
	acceleration_structure_max_num:    u32,
}

Descriptor_Range_Bits :: enum u8 {
	Partially_Bound,
	Array,
	Variable_Sized_Array,
}
Descriptor_Range_Flags :: bit_set[Descriptor_Range_Bits;u32]

Descriptor_Range_Desc :: struct {
	base_register_index, descriptor_num: u32,
	descriptor_type:                     Descriptor_Type,
	shader_stages:                       Stage_Flags,
	flags:                               Descriptor_Range_Flags,
}

Dynamic_Constant_Buffer_Desc :: struct {
	register_index: u32,
	shader_stages:  Stage_Flags,
}

Descriptor_Set_Desc :: struct {
	register_space:              u32,
	ranges:                      [^]Descriptor_Range_Desc,
	range_num:                   u32,
	dynamic_constant_buffers:    [^]Dynamic_Constant_Buffer_Desc,
	dynamic_constant_buffer_num: u32,
}

Root_Constant_Desc :: struct {
	register_index, size: u32,
	shader_stages:        Stage_Flags,
}

Root_Descriptor_Desc :: struct {
	register_index:  u32,
	// Constant_Buffer, Structured_Buffer or Storage_Structured_Buffer
	descriptor_type: Descriptor_Type,
	shader_stages:   Stage_Flags,
}

Pipeline_Layout_Desc :: struct {
	root_register_space:                    u32,
	root_constants:                         [^]Root_Constant_Desc,
	root_constant_num:                      u32,
	root_descriptors:                       [^]Root_Descriptor_Desc,
	root_descriptor_num:                    u32,
	descriptor_sets:                        [^]Descriptor_Set_Desc,
	descriptor_set_num:                     u32,
	shader_stages:                          Stage_Flags,
	ignore_global_spirv_offsets:            bool,
	enable_d3d12_draw_parameters_emulation: bool,
}

Descriptor_Range_Update_Desc :: struct {
	descriptors:     [^]^Descriptor,
	descriptor_num:  u32,
	base_descriptor: u32,
}

Descriptor_Set_Copy_Desc :: struct {
	src_descriptor_set:                        ^Descriptor_Set,
	src_base_range, dst_base_range, range_num: u32,
	src_base_dynamic_constant_buffer:          u32,
	dst_base_dynamic_constant_buffer:          u32,
	dynamic_constant_buffer_num:               u32,
}

Vertex_Stream_Step_Rate :: enum u8 {
	Per_Vertex,
	Per_Instance,
}

Index_Type :: enum u8 {
	Uint16,
	Uint32,
}

Primitive_Restart :: enum u8 {
	Disabled,
	Indices_Uint16,
	Indices_Uint32,
}

Topology :: enum u8 {
	Point_List,
	Line_List,
	Line_Strip,
	Triangle_List,
	Triangle_Strip,
	Line_List_With_Adjacency,
	Line_Strip_With_Adjacency,
	Triangle_List_With_Adjacency,
	Triangle_Strip_With_Adjacency,
	Patch_List,
}

Input_Assembly_Desc :: struct {
	topology:               Topology,
	tess_control_point_num: u8,
	primitive_restart:      Primitive_Restart,
}

Vertex_Attribute_D3D :: struct {
	semantic_name:  string,
	semantic_index: u32,
}

Vertex_Attribute_VK :: struct {
	location: u32,
}

Vertex_Attribute_Desc :: struct {
	d3d:          Vertex_Attribute_D3D,
	vk:           Vertex_Attribute_VK,
	offset:       u32,
	format:       Format,
	stream_index: u16,
}

Vertex_Stream_Desc :: struct {
	stride:       u16,
	binding_slot: u16,
	step_rate:    Vertex_Stream_Step_Rate,
}

Vertex_Input_Desc :: struct {
	attributes:    [^]Vertex_Attribute_Desc,
	attribute_num: u32,
	streams:       [^]Vertex_Stream_Desc,
	stream_num:    u32,
}

Fill_Mode :: enum u8 {
	Solid,
	Wireframe,
}

Cull_Mode :: enum u8 {
	None,
	Front,
	Back,
}

Shading_Rate :: enum u8 {
	Fragment_Size_1x1,
	Fragment_Size_1x2,
	Fragment_Size_2x1,
	Fragment_Size_2x2,

	// Require "is_additional_shading_rates_supported"
	Fragment_Size_2x4,
	Fragment_Size_4x2,
	Fragment_Size_4x4,
}

Shading_Rate_Combiner :: enum u8 {
	Replace,
	Keep,
	Min,
	Max,
	Sum,
}

/*
R - minimum resolvable difference
S - maximum slope

bias = constant * R + slopeFactor * S
if (clamp > 0)
    bias = min(bias, clamp)
else if (clamp < 0)
    bias = max(bias, clamp)

enabled if constant != 0 or slope != 0
*/
Depth_Bias_Desc :: struct {
	constant, clamp, slope: f32,
}

Rasterization_Desc :: struct {
	viewport_num:            u32,
	depth_bias:              Depth_Bias_Desc,
	fill_mode:               Fill_Mode,
	cull_mode:               Cull_Mode,
	front_counter_clockwise: bool,
	depth_clamp:             bool,
	line_smoothing:          bool,
	conservative_raster:     bool,
	shading_rate:            bool,
}

Multisample_Desc :: struct {
	sample_mask:                         u32,
	sample_num:                          sample,
	alpha_to_coverage, sample_locations: bool,
}

Shading_Rate_Desc :: struct {
	shading_rate:                            Shading_Rate,
	primitive_combiner, attachment_combiner: Shading_Rate_Combiner,
}

// S - source color 0
// D - destination color
Logic_Func :: enum u8 {
	None,
	// 0
	Clear,
	// S & D
	And,
	// S & ~D
	And_Reverse,
	// S
	Copy,
	// ~S & D
	And_Inverted,
	// S ^ D
	Xor,
	// S | D
	Or,
	// ~(S | D)
	Nor,
	// ~(S ^ D)
	Equivalent,
	// ~D
	Invert,
	// S | ~D
	Or_Reverse,
	// ~S
	Copy_Inverted,
	// ~S | D
	Or_Inverted,
	// ~(S & D)
	Nand,
	// 1
	Set,
}


// R - fragment's depth or stencil reference
// D - depth or stencil buffer
Compare_Func :: enum u8 {
	// test is disabled
	None,
	// true
	Always,
	// false
	Never,
	// R == D
	Equal,
	// R != D
	Not_Equal,
	// R < D
	Less,
	// R <= D
	Less_Equal,
	// R > D
	Greater,
	// R >= D
	Greater_Equal,
}

// R - reference, set by "CmdSetStencilReference"
// D - stencil buffer
Stencil_Func :: enum u8 {
	// D = D
	Keep,
	// D = 0
	Zero,
	// D = R
	Replace,
	// D = min(D++, 255)
	Increment_And_Clamp,
	// D = max(D--, 0)
	Decrement_And_Clamp,
	// D = ~D
	Invert,
	// D++
	Increment_And_Wrap,
	// D--
	Decrement_And_Wrap,
}

// S0 - source color 0
// S1 - source color 1
// D - destination color
// C - blend constants, set by "CmdSetBlendConstants"
Blend_Factor :: enum u8 {
	// 0
	Zero,
	// 1
	One,
	// S0.r, S0.g, S0.b
	Src_Color,
	// 1 - S0.r, 1 - S0.g, 1 - S0.b
	One_Minus_Src_Color,
	// D.r, D.g, D.b
	Dst_Color,
	// 1 - D.r, 1 - D.g, 1 - D.b
	One_Minus_Dst_Color,
	// S0.a
	Src_Alpha,
	// 1 - S0.a
	One_Minus_Src_Alpha,
	// D.a
	Dst_Alpha,
	// 1 - D.a
	One_Minus_Dst_Alpha,
	// C.r, C.g, C.b
	Constant_Color,
	// 1 - C.r, 1 - C.g, 1 - C.b
	One_Minus_Constant_Color,
	// C.a
	Constant_Alpha,
	// 1 - C.a
	One_Minus_Constant_Alpha,
	// min(S0.a, 1 - D.a)
	Src_Alpha_Saturate,
	// S1.r, S1.g, S1.b
	Src1_Color,
	// 1 - S1.r, 1 - S1.g, 1 - S1.b
	One_Minus_Src1_Color,
	// S1.a
	Src1_Alpha,
	// 1 - S1.a
	One_Minus_Src1_Alpha,
}

// S - source color
// D - destination color
// Sf - source factor, produced by "BlendFactor"
// Df - destination factor, produced by "BlendFactor"
Blend_Func :: enum u8 {
	// S * Sf + D * Df
	Add,
	// S * Sf - D * Df
	Subtract,
	// D * Df - S * Sf
	Reverse_Subtract,
	// min(S, D)
	Min,
	// max(S, D)
	Max,
}

Color_Write_Bits :: enum u8 {
	R,
	G,
	B,
	A,
}
Color_Write_Flags :: bit_set[Color_Write_Bits;u8]
Color_Write_RGBA: Color_Write_Flags : {.R, .G, .B, .A}
Color_Write_RGB: Color_Write_Flags : {.R, .G, .B}

Clear_Desc :: struct {
	value:                  Clear_Value,
	planes:                 Plane_Flags,
	color_attachment_index: u32,
}

Stencil_Desc :: struct {
	compare_func:             Compare_Func,
	fail:                     Stencil_Func,
	pass:                     Stencil_Func,
	depth_fail:               Stencil_Func,
	write_mask, compare_mask: u8,
}

Blending_Desc :: struct {
	src_factor, dst_factor: Blend_Factor,
	func:                   Blend_Func,
}

Color_Attachment_Desc :: struct {
	format:                   Format,
	color_blend, alpha_blend: Blending_Desc,
	color_write_mask:         Color_Write_Flags,
	blend_enabled:            bool,
}

Depth_Attachment_Desc :: struct {
	compare_func:       Compare_Func,
	write, bounds_test: bool,
}

Stencil_Attachment_Desc :: struct {
	front, back: Stencil_Desc,
}

Output_Merger_Desc :: struct {
	colors:               [^]Color_Attachment_Desc,
	color_num:            u32,
	depth:                Depth_Attachment_Desc,
	stencil:              Stencil_Attachment_Desc,
	depth_stencil_format: Format,
	logic_func:           Logic_Func,
}

Attachments_Desc :: struct {
	depth_stencil, shading_rate: ^Descriptor,
	colors:                      [^]^Descriptor,
	color_num:                   u32,
}

Filter :: enum u8 {
	Nearest,
	Linear,
}

Filter_Ext :: enum u8 {
	None,
	Min,
	Max,
}

Address_Mode :: enum u8 {
	Repeat,
	Mirrored_Repeat,
	Clamp_To_Edge,
	Clamp_To_Border,
	Mirror_Clamp_To_Edge,
}

Address_Modes :: struct {
	u, v, w: Address_Mode,
}

Filters :: struct {
	min, mag, mip: Filter,
	ext:           Filter_Ext,
}

Sampler_Desc :: struct {
	filters:                    Filters,
	anisotropy:                 u8,
	mip_bias, mip_min, mip_max: f32,
	address_modes:              Address_Modes,
	compare_func:               Compare_Func,
	border_color:               Color,
	is_integer:                 bool,
}

Shader_Desc :: struct {
	stage:            Stage_Flags,
	bytecode:         [^]u8,
	bytecode_size:    u64,
	entry_point_name: string,
}

Graphics_Pipeline_Desc :: struct {
	pipeline_layout: ^Pipeline_Layout,
	vertex_input:    Vertex_Input_Desc,
	input_assembly:  Input_Assembly_Desc,
	rasterization:   Rasterization_Desc,
	multisample:     Multisample_Desc,
	output_merger:   Output_Merger_Desc,
	shaders:         [^]Shader_Desc,
	shader_num:      u32,
}

Compute_Pipeline_Desc :: struct {
	pipeline_layout: ^Pipeline_Layout,
	shader:          Shader_Desc,
}

Access_Bits :: enum u16 {
	Unknown,
	Index_Buffer, // INDEX_INPUT
	Vertex_Buffer, // VERTEX_SHADER
	Constant_Buffer, // GRAPHICS_SHADERS, COMPUTE_SHADER, RAY_TRACING_SHADERS
	Shader_Resource, // GRAPHICS_SHADERS, COMPUTE_SHADER, RAY_TRACING_SHADERS
	Shader_Resource_Storage, // GRAPHICS_SHADERS, COMPUTE_SHADER, RAY_TRACING_SHADERS, CLEAR_STORAGE
	Argument_Buffer, // INDIRECT
	Color_Attachment, // COLOR_ATTACHMENT
	Depth_Stencil_Attachment_Write, // DEPTH_STENCIL_ATTACHMENT
	Depth_Stencil_Attachment_Read, // DEPTH_STENCIL_ATTACHMENT
	Copy_Source, // COPY
	Copy_Destination, // COPY
	Resolve_Source, // RESOLVE
	Resolve_Destination, // RESOLVE
	Acceleration_Structure_Read, // COMPUTE_SHADER, RAY_TRACING_SHADERS, ACCELERATION_STRUCTURE
	Acceleration_Structure_Write, // COMPUTE_SHADER, RAY_TRACING_SHADERS, ACCELERATION_STRUCTURE
	Shading_Rate_Attachment, // FRAGMENT_SHADER
}
Access_Flags :: bit_set[Access_Bits;u32]

Layout :: enum u8 {
	Unknown,
	Color_Attachment, // COLOR_ATTACHMENT
	Depth_Stencil_Attachment, // DEPTH_STENCIL_ATTACHMENT_WRITE
	Depth_Stencil_Readonly, // DEPTH_STENCIL_ATTACHMENT_READ, SHADER_RESOURCE
	Shader_Resource, // SHADER_RESOURCE
	Shader_Resource_Storage, // SHADER_RESOURCE_STORAGE
	Copy_Source, // COPY_SOURCE
	Copy_Destination, // COPY_DESTINATION
	Resolve_Source, // RESOLVE_SOURCE
	Resolve_Destination, // RESOLVE_DESTINATION
	Present, // UNKNOWN
	Shading_Rate_Attachment, // SHADING_RATE_ATTACHMENT
}

Access_Stage :: struct {
	access: Access_Flags,
	stages: Stage_Flags,
}

Access_Layout_Stage :: struct {
	access: Access_Flags,
	layout: Layout,
	stages: Stage_Flags,
}

Global_Barrier_Desc :: struct {
	before, after: Access_Stage,
}

Buffer_Barrier_Desc :: struct {
	buffer:        ^Buffer,
	before, after: Access_Stage,
}

Texture_Barrier_Desc :: struct {
	texture:                 ^Texture,
	before, after:           Access_Layout_Stage,
	mip_offset, mip_num:     mip,
	layer_offset, layer_num: dim,
	planes:                  Plane_Flags,
}

Barrier_Group_Desc :: struct {
	globals:     [^]Global_Barrier_Desc,
	global_num:  u32,
	buffers:     [^]Buffer_Barrier_Desc,
	buffer_num:  u32,
	textures:    [^]Texture_Barrier_Desc,
	texture_num: u32,
}

Texture_Region_Desc :: struct {
	x, y, z:              u16,
	width, height, depth: dim,
	mip_offset:           mip,
	layer_offset:         dim,
}

Texture_Data_Layout_Desc :: struct {
	offset:      u64,
	row_pitch:   u32,
	slice_pitch: u32,
}

Fence_Submit_Desc :: struct {
	fence:  ^Fence,
	value:  u64,
	stages: Stage_Flags,
}

Queue_Submit_Desc :: struct {
	wait_fences:      [^]Fence_Submit_Desc,
	wait_fence_num:   u32,
	command_buffers:  [^]^Command_Buffer,
	command_num:      u32,
	signal_fences:    [^]Fence_Submit_Desc,
	signal_fence_num: u32,
}

Memory_Desc :: struct {
	size, alignment:   u64,
	type:              memory_type,
	must_be_dedicated: bool,
}

Allocate_Memory_Desc :: struct {
	size:     u64,
	type:     memory_type,
	priority: f32,
}

Buffer_Memory_Binding_Desc :: struct {
	memory: ^Memory,
	buffer: ^Buffer,
	offset: u64,
}

Texture_Memory_Binding_Desc :: struct {
	memory:  ^Memory,
	texture: ^Texture,
	offset:  u64,
}

Clear_Storage_Buffer_Desc :: struct {
	storage_buffer:                           ^Descriptor,
	value:                                    u32,
	set_index, range_index, descriptor_index: u32,
}

Clear_Storage_Texture_Desc :: struct {
	storage_texture:                          ^Descriptor,
	value:                                    Clear_Value,
	set_index, range_index, descriptor_index: u32,
}

Draw_Desc :: struct {
	vertex_num:    u32,
	instance_num:  u32,
	base_vertex:   u32,
	base_instance: u32,
}

Draw_Indexed_Desc :: struct {
	index_num:     u32,
	instance_num:  u32,
	base_index:    u32,
	base_vertex:   u32,
	base_instance: u32,
}

Dispatch_Desc :: struct {
	x, y, z: u32,
}

Draw_Emulated_Desc :: struct {
	shader_emulated_base_vertex:   u32,
	shader_emulated_base_instance: u32,
	vertex_num:                    u32,
	instance_num:                  u32,
	base_vertex:                   u32,
	base_instance:                 u32,
}

Draw_Indexed_Emulated_Desc :: struct {
	shader_emulated_base_vertex:   u32,
	shader_emulated_base_instance: u32,
	index_num:                     u32,
	instance_num:                  u32,
	base_index:                    u32,
	base_vertex:                   u32,
	base_instance:                 u32,
}

Query_Type :: enum u8 {
	Timestamp,
	Timestamp_Copy_Queue,
	Occlusion,
	Pipeline_Statistics,
	Acceleration_Structure_Compacted_Size,
}

Query_Pool_Desc :: struct {
	query_type: Query_Type,
	capacity:   u32,
}

Pipeline_Statistics_Desc :: struct {
	input_vertex_num:                      u64,
	input_primitive_num:                   u64,
	vertex_shader_invocation_num:          u64,
	geometry_shader_invocation_num:        u64,
	geometry_shader_primitive_num:         u64,
	rasterizer_in_primitive_num:           u64,
	rasterizer_out_primitive_num:          u64,
	fragment_shader_invocation_num:        u64,
	tess_control_shader_invocation_num:    u64,
	tess_evaluation_shader_invocation_num: u64,
	compute_shader_invocation_num:         u64,
	mesh_control_shader_invocation_num:    u64,
	mesh_evaluation_shader_invocation_num: u64,
	mesh_evaluation_shader_primitive_num:  u64,
}

Vendor :: enum u8 {
	UNKNOWN,
	NVIDIA,
	AMD,
	INTEL,
}

Adapter_Desc :: struct {
	name:                                        [256]u8,
	luid, video_memory_size, system_memory_size: u64,
	device_id:                                   u32,
	vendor:                                      Vendor,
}

Device_Desc :: struct {
	adapter_desc:                                                                          Adapter_Desc,
	graphics_api:                                                                          Graphics_API,
	viewport_max_num:                                                                      u32,
	viewport_bounds_range:                                                                 [2]i32,
	attachment_max_dim, attachment_layer_max_num, color_attachment_max_num:                dim,
	color_sample_max_num:                                                                  sample,
	depth_sample_max_num:                                                                  sample,
	stencil_sample_max_num:                                                                sample,
	zero_attachments_sample_max_num:                                                       sample,
	texture_color_sample_max_num:                                                          sample,
	texture_integer_sample_max_num:                                                        sample,
	texture_depth_sample_max_num:                                                          sample,
	texture_stencil_sample_max_num:                                                        sample,
	storage_texture_sample_max_num:                                                        sample,
	texture_1d_max_dim:                                                                    dim,
	texture_2d_max_dim:                                                                    dim,
	texture_3d_max_dim:                                                                    dim,
	texture_array_layer_max_num:                                                           dim,
	typed_buffer_max_dim:                                                                  u32,
	device_upload_heap_size:                                                               u64,
	memory_allocation_max_num:                                                             u32,
	sampler_allocation_max_num:                                                            u32,
	constant_buffer_max_range:                                                             u32,
	storage_buffer_max_range:                                                              u32,
	buffer_texture_granularity:                                                            u32,
	buffer_max_size:                                                                       u64,
	upload_buffer_texture_row_alignment:                                                   u32,
	upload_buffer_texture_slice_alignment:                                                 u32,
	buffer_shader_resource_offset_alignment:                                               u32,
	constant_buffer_offset_alignment:                                                      u32,
	scratch_buffer_offset_alignment:                                                       u32,
	shader_binding_table_alignment:                                                        u32,
	pipeline_layout_descriptor_set_max_num:                                                u32,
	pipeline_layout_root_constant_max_size:                                                u32,
	pipeline_layout_root_descriptor_max_num:                                               u32,
	descriptor_set_sampler_max_num:                                                        u32,
	descriptor_set_constant_buffer_max_num:                                                u32,
	descriptor_set_storage_buffer_max_num:                                                 u32,
	descriptor_set_texture_max_num:                                                        u32,
	descriptor_set_storage_texture_max_num:                                                u32,
	per_stage_descriptor_sampler_max_num:                                                  u32,
	per_stage_descriptor_constant_buffer_max_num:                                          u32,
	per_stage_descriptor_storage_buffer_max_num:                                           u32,
	per_stage_descriptor_texture_max_num:                                                  u32,
	per_stage_descriptor_storage_texture_max_num:                                          u32,
	per_stage_resource_max_num:                                                            u32,
	vertex_shader_attribute_max_num:                                                       u32,
	vertex_shader_stream_max_num:                                                          u32,
	vertex_shader_output_component_max_num:                                                u32,
	tess_control_shader_generation_max_level:                                              f32,
	tess_control_shader_patch_point_max_num:                                               u32,
	tess_control_shader_per_vertex_input_component_max_num:                                u32,
	tess_control_shader_per_vertex_output_component_max_num:                               u32,
	tess_control_shader_per_patch_output_component_max_num:                                u32,
	tess_control_shader_total_output_component_max_num:                                    u32,
	tess_evaluation_shader_input_component_max_num:                                        u32,
	tess_evaluation_shader_output_component_max_num:                                       u32,
	geometry_shader_invocation_max_num:                                                    u32,
	geometry_shader_input_component_max_num:                                               u32,
	geometry_shader_output_component_max_num:                                              u32,
	geometry_shader_output_vertex_max_num:                                                 u32,
	geometry_shader_total_output_component_max_num:                                        u32,
	fragment_shader_input_component_max_num:                                               u32,
	fragment_shader_output_attachment_max_num:                                             u32,
	fragment_shader_dual_source_attachment_max_num:                                        u32,
	compute_shader_shared_memory_max_size, compute_shader_work_group_max_num:              [3]u32,
	compute_shader_work_group_invocation_max_num, compute_shader_work_group_max_dim:       [3]u32,
	ray_tracing_shader_group_identifier_size:                                              u32,
	ray_tracing_shader_table_max_stride:                                                   u32,
	ray_tracing_shader_recursion_max_depth:                                                u32,
	ray_tracing_geometry_object_max_num:                                                   u32,
	mesh_control_shared_memory_max_size:                                                   u32,
	mesh_control_work_group_invocation_max_num:                                            u32,
	mesh_control_payload_max_size:                                                         u32,
	mesh_evaluation_output_vertices_max_num:                                               u32,
	mesh_evaluation_output_primitive_max_num:                                              u32,
	mesh_evaluation_output_component_max_num:                                              u32,
	mesh_evaluation_shared_memory_max_size:                                                u32,
	mesh_evaluation_work_group_invocation_max_num:                                         u32,
	viewport_precision_bits:                                                               u32,
	sub_pixel_precision_bits:                                                              u32,
	sub_texel_precision_bits:                                                              u32,
	mipmap_precision_bits:                                                                 u32,
	timestamp_frequency_hz:                                                                u64,
	draw_indirect_max_num:                                                                 u32,
	sampler_lod_bias_min, sampler_lod_bias_max, sampler_anisotropy_max:                    f32,
	texel_offset_min, texel_offset_max, texel_gather_offset_min, texel_gather_offset_max:  i32,
	clip_distance_max_num, cull_distance_max_num, combined_clip_and_cull_distance_max_num: u32,
	shading_rate_attachment_tile_size, shader_model:                                       u8,
	conservative_raster_tier:                                                              u8,
	sample_locations_tier:                                                                 u8,
	ray_tracing_tier:                                                                      u8,
	shading_rate_tier:                                                                     u8,
	bindless_tier:                                                                         u8,
	is_compute_queue_supported:                                                            bool,
	is_copy_queue_supported:                                                               bool,
	is_texture_filter_min_max_supported:                                                   bool,
	is_logic_func_supported:                                                               bool,
	is_depth_bounds_test_supported:                                                        bool,
	is_draw_indirect_count_supported:                                                      bool,
	is_independent_front_and_back_stencil_reference_and_masks_supported:                   bool,
	is_line_smoothing_supported:                                                           bool,
	is_copy_queue_timestamp_supported:                                                     bool,
	is_mesh_shader_pipeline_stats_supported:                                               bool,
	is_enchanced_barrier_supported:                                                        bool,
	is_memory_tier2_supported:                                                             bool,
	is_dynamic_depth_bias_supported:                                                       bool,
	is_additional_shading_rates_supported:                                                 bool,
	is_viewport_origin_bottom_left_supported:                                              bool,
	is_region_resolve_supported:                                                           bool,
	is_shader_native_i16_supported:                                                        bool,
	is_shader_native_f16_supported:                                                        bool,
	is_shader_native_i32_supported:                                                        bool,
	is_shader_native_f32_supported:                                                        bool,
	is_shader_native_i64_supported:                                                        bool,
	is_shader_native_f64_supported:                                                        bool,
	is_shader_atomics_i16_supported:                                                       bool,
	is_shader_atomics_f16_supported:                                                       bool,
	is_shader_atomics_i32_supported:                                                       bool,
	is_shader_atomics_f32_supported:                                                       bool,
	is_shader_atomics_i64_supported:                                                       bool,
	is_shader_atomics_f64_supported:                                                       bool,
	is_draw_parameters_emulation_enabled:                                                  bool,
	is_swap_chain_supported:                                                               bool,
	is_ray_tracing_supported:                                                              bool,
	is_mesh_shader_supported:                                                              bool,
	is_low_latency_supported:                                                              bool,
}

GetDeviceDesc_func_ptr_anon_0 :: #type proc "c" (device: ^Device) -> ^Device_Desc
GetBufferDesc_func_ptr_anon_1 :: #type proc "c" (buffer: ^Buffer) -> ^Buffer_Desc
GetTextureDesc_func_ptr_anon_2 :: #type proc "c" (texture: ^Texture) -> ^Texture_Desc
GetFormatSupport_func_ptr_anon_3 :: #type proc "c" (
	device: ^Device,
	format: Format,
) -> Format_Support_Bits
GetQuerySize_func_ptr_anon_4 :: #type proc "c" (queryPool: ^Query_Pool) -> u32
GetBufferMemoryDesc_func_ptr_anon_5 :: #type proc "c" (
	device: ^Device,
	#by_ptr bufferDesc: Buffer_Desc,
	memoryLocation: Memory_Location,
	memoryDesc: ^Memory_Desc,
)
GetTextureMemoryDesc_func_ptr_anon_6 :: #type proc "c" (
	device: ^Device,
	#by_ptr textureDesc: Texture_Desc,
	memoryLocation: Memory_Location,
	memoryDesc: ^Memory_Desc,
)
GetCommandQueue_func_ptr_anon_7 :: #type proc "c" (
	device: ^Device,
	commandQueueType: Command_Queue_Type,
	commandQueue: ^^Command_Queue,
) -> Result
CreateCommandAllocator_func_ptr_anon_8 :: #type proc "c" (
	commandQueue: ^Command_Queue,
	commandAllocator: ^^Command_Allocator,
) -> Result
CreateCommandBuffer_func_ptr_anon_9 :: #type proc "c" (
	commandAllocator: ^Command_Allocator,
	commandBuffer: ^^Command_Buffer,
) -> Result
CreateDescriptorPool_func_ptr_anon_10 :: #type proc "c" (
	device: ^Device,
	#by_ptr descriptorPoolDesc: Descriptor_Pool_Desc,
	descriptorPool: ^^Descriptor_Pool,
) -> Result
CreateBuffer_func_ptr_anon_11 :: #type proc "c" (
	device: ^Device,
	#by_ptr bufferDesc: Buffer_Desc,
	buffer: ^^Buffer,
) -> Result
CreateTexture_func_ptr_anon_12 :: #type proc "c" (
	device: ^Device,
	#by_ptr textureDesc: Texture_Desc,
	texture: ^^Texture,
) -> Result
CreateBufferView_func_ptr_anon_13 :: #type proc "c" (
	#by_ptr bufferViewDesc: Buffer_View_Desc,
	bufferView: ^^Descriptor,
) -> Result
CreateTexture1DView_func_ptr_anon_14 :: #type proc "c" (
	#by_ptr textureViewDesc: Texture_1D_View_Desc,
	textureView: ^^Descriptor,
) -> Result
CreateTexture2DView_func_ptr_anon_15 :: #type proc "c" (
	#by_ptr textureViewDesc: Texture_2D_View_Desc,
	textureView: ^^Descriptor,
) -> Result
CreateTexture3DView_func_ptr_anon_16 :: #type proc "c" (
	#by_ptr textureViewDesc: Texture_3D_View_Desc,
	textureView: ^^Descriptor,
) -> Result
CreateSampler_func_ptr_anon_17 :: #type proc "c" (
	device: ^Device,
	#by_ptr samplerDesc: Sampler_Desc,
	sampler: ^^Descriptor,
) -> Result
CreatePipelineLayout_func_ptr_anon_18 :: #type proc "c" (
	device: ^Device,
	#by_ptr pipelineLayoutDesc: Pipeline_Layout_Desc,
	pipelineLayout: ^^Pipeline_Layout,
) -> Result
CreateGraphicsPipeline_func_ptr_anon_19 :: #type proc "c" (
	device: ^Device,
	#by_ptr graphicsPipelineDesc: Graphics_Pipeline_Desc,
	pipeline: ^^Pipeline,
) -> Result
CreateComputePipeline_func_ptr_anon_20 :: #type proc "c" (
	device: ^Device,
	#by_ptr computePipelineDesc: Compute_Pipeline_Desc,
	pipeline: ^^Pipeline,
) -> Result
CreateQueryPool_func_ptr_anon_21 :: #type proc "c" (
	device: ^Device,
	#by_ptr queryPoolDesc: Query_Pool_Desc,
	queryPool: ^^Query_Pool,
) -> Result
CreateFence_func_ptr_anon_22 :: #type proc "c" (
	device: ^Device,
	initialValue: u64,
	fence: ^^Fence,
) -> Result
DestroyCommandAllocator_func_ptr_anon_23 :: #type proc "c" (commandAllocator: ^Command_Allocator)
DestroyCommandBuffer_func_ptr_anon_24 :: #type proc "c" (commandBuffer: ^Command_Buffer)
DestroyDescriptorPool_func_ptr_anon_25 :: #type proc "c" (descriptorPool: ^Descriptor_Pool)
DestroyBuffer_func_ptr_anon_26 :: #type proc "c" (buffer: ^Buffer)
DestroyTexture_func_ptr_anon_27 :: #type proc "c" (texture: ^Texture)
DestroyDescriptor_func_ptr_anon_28 :: #type proc "c" (descriptor: ^Descriptor)
DestroyPipelineLayout_func_ptr_anon_29 :: #type proc "c" (pipelineLayout: ^Pipeline_Layout)
DestroyPipeline_func_ptr_anon_30 :: #type proc "c" (pipeline: ^Pipeline)
DestroyQueryPool_func_ptr_anon_31 :: #type proc "c" (queryPool: ^Query_Pool)
DestroyFence_func_ptr_anon_32 :: #type proc "c" (fence: ^Fence)
AllocateMemory_func_ptr_anon_33 :: #type proc "c" (
	device: ^Device,
	#by_ptr allocateMemoryDesc: Allocate_Memory_Desc,
	memory: ^^Memory,
) -> Result
BindBufferMemory_func_ptr_anon_34 :: #type proc "c" (
	device: ^Device,
	memoryBindingDescs: [^]Buffer_Memory_Binding_Desc,
	memoryBindingDescNum: u32,
) -> Result
BindTextureMemory_func_ptr_anon_35 :: #type proc "c" (
	device: ^Device,
	memoryBindingDescs: [^]Texture_Memory_Binding_Desc,
	memoryBindingDescNum: u32,
) -> Result
FreeMemory_func_ptr_anon_36 :: #type proc "c" (memory: ^Memory)
BeginCommandBuffer_func_ptr_anon_37 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	descriptorPool: ^Descriptor_Pool,
) -> Result
CmdSetDescriptorPool_func_ptr_anon_38 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	descriptorPool: ^Descriptor_Pool,
)
CmdSetPipelineLayout_func_ptr_anon_39 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	pipelineLayout: ^Pipeline_Layout,
)
CmdSetDescriptorSet_func_ptr_anon_40 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	setIndex: u32,
	descriptorSet: ^Descriptor_Set,
	dynamicConstantBufferOffsets: [^]u32,
)
CmdSetRootConstants_func_ptr_anon_41 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	rootConstantIndex: u32,
	data: rawptr,
	size: u32,
)
CmdSetRootDescriptor_func_ptr_anon_42 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	rootDescriptorIndex: u32,
	descriptor: ^Descriptor,
)
CmdSetPipeline_func_ptr_anon_43 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	pipeline: ^Pipeline,
)
CmdBarrier_func_ptr_anon_44 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	#by_ptr barrierGroupDesc: Barrier_Group_Desc,
)
CmdSetIndexBuffer_func_ptr_anon_45 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	buffer: ^Buffer,
	offset: u64,
	indexType: Index_Type,
)
CmdSetVertexBuffers_func_ptr_anon_46 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	baseSlot: u32,
	bufferNum: u32,
	buffers: [^]^Buffer,
	offsets: [^]u64,
)
CmdSetViewports_func_ptr_anon_47 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	viewports: [^]Viewport,
	viewportNum: u32,
)
CmdSetScissors_func_ptr_anon_48 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	rects: [^]Rect,
	rectNum: u32,
)
CmdSetStencilReference_func_ptr_anon_49 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	frontRef: u8,
	backRef: u8,
)
CmdSetDepthBounds_func_ptr_anon_50 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	boundsMin: f32,
	boundsMax: f32,
)
CmdSetBlendConstants_func_ptr_anon_51 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	color: ^Colorf,
)
CmdSetSampleLocations_func_ptr_anon_52 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	locations: [^]Sample_Location,
	locationNum: sample,
	sampleNum: sample,
)
CmdSetShadingRate_func_ptr_anon_53 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	#by_ptr shadingRateDesc: Shading_Rate_Desc,
)
CmdSetDepthBias_func_ptr_anon_54 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	#by_ptr depthBiasDesc: Depth_Bias_Desc,
)
CmdBeginRendering_func_ptr_anon_55 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	#by_ptr attachmentsDesc: Attachments_Desc,
)
CmdClearAttachments_func_ptr_anon_56 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	clearDescs: [^]Clear_Desc,
	clearDescNum: u32,
	rects: [^]Rect,
	rectNum: u32,
)
CmdDraw_func_ptr_anon_57 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	#by_ptr drawDesc: Draw_Desc,
)
CmdDrawIndexed_func_ptr_anon_58 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	#by_ptr drawIndexedDesc: Draw_Indexed_Desc,
)
CmdDrawIndirect_func_ptr_anon_59 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	buffer: ^Buffer,
	offset: u64,
	drawNum: u32,
	stride: u32,
	countBuffer: ^Buffer,
	countBufferOffset: u64,
)
CmdDrawIndexedIndirect_func_ptr_anon_60 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	buffer: ^Buffer,
	offset: u64,
	drawNum: u32,
	stride: u32,
	countBuffer: ^Buffer,
	countBufferOffset: u64,
)
CmdEndRendering_func_ptr_anon_61 :: #type proc "c" (commandBuffer: ^Command_Buffer)
CmdDispatch_func_ptr_anon_62 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	#by_ptr dispatchDesc: Dispatch_Desc,
)
CmdDispatchIndirect_func_ptr_anon_63 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	buffer: ^Buffer,
	offset: u64,
)
CmdCopyBuffer_func_ptr_anon_64 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	dstBuffer: ^Buffer,
	dstOffset: u64,
	srcBuffer: ^Buffer,
	srcOffset: u64,
	size: u64,
)
CmdCopyTexture_func_ptr_anon_65 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	dstTexture: ^Texture,
	#by_ptr dstRegionDesc: Texture_Region_Desc,
	srcTexture: ^Texture,
	#by_ptr srcRegionDesc: Texture_Region_Desc,
)
CmdResolveTexture_func_ptr_anon_66 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	dstTexture: ^Texture,
	#by_ptr dstRegionDesc: Texture_Region_Desc,
	srcTexture: ^Texture,
	#by_ptr srcRegionDesc: Texture_Region_Desc,
)
CmdUploadBufferToTexture_func_ptr_anon_67 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	dstTexture: ^Texture,
	#by_ptr dstRegionDesc: Texture_Region_Desc,
	srcBuffer: ^Buffer,
	#by_ptr srcDataLayoutDesc: Texture_Data_Layout_Desc,
)
CmdReadbackTextureToBuffer_func_ptr_anon_68 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	dstBuffer: ^Buffer,
	#by_ptr dstDataLayoutDesc: Texture_Data_Layout_Desc,
	srcTexture: ^Texture,
	#by_ptr srcRegionDesc: Texture_Region_Desc,
)
CmdClearStorageBuffer_func_ptr_anon_69 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	#by_ptr clearDesc: Clear_Storage_Buffer_Desc,
)
CmdClearStorageTexture_func_ptr_anon_70 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	#by_ptr clearDesc: Clear_Storage_Texture_Desc,
)
CmdResetQueries_func_ptr_anon_71 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	queryPool: ^Query_Pool,
	offset: u32,
	num: u32,
)
CmdBeginQuery_func_ptr_anon_72 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	queryPool: ^Query_Pool,
	offset: u32,
)
CmdEndQuery_func_ptr_anon_73 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	queryPool: ^Query_Pool,
	offset: u32,
)
CmdCopyQueries_func_ptr_anon_74 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	queryPool: ^Query_Pool,
	offset: u32,
	num: u32,
	dstBuffer: ^Buffer,
	dstOffset: u64,
)
CmdBeginAnnotation_func_ptr_anon_75 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	name: cstring,
)
CmdEndAnnotation_func_ptr_anon_76 :: #type proc "c" (commandBuffer: ^Command_Buffer)
EndCommandBuffer_func_ptr_anon_77 :: #type proc "c" (commandBuffer: ^Command_Buffer) -> Result
QueueSubmit_func_ptr_anon_78 :: #type proc "c" (
	commandQueue: ^Command_Queue,
	#by_ptr queueSubmitDesc: Queue_Submit_Desc,
)
Wait_func_ptr_anon_79 :: #type proc "c" (fence: ^Fence, value: u64)
GetFenceValue_func_ptr_anon_80 :: #type proc "c" (fence: ^Fence) -> u64
UpdateDescriptorRanges_func_ptr_anon_81 :: #type proc "c" (
	descriptorSet: ^Descriptor_Set,
	baseRange: u32,
	rangeNum: u32,
	rangeUpdateDescs: [^]Descriptor_Range_Update_Desc,
)
UpdateDynamicConstantBuffers_func_ptr_anon_82 :: #type proc "c" (
	descriptorSet: ^Descriptor_Set,
	baseDynamicConstantBuffer: u32,
	dynamicConstantBufferNum: u32,
	descriptors: [^]^Descriptor,
)
CopyDescriptorSet_func_ptr_anon_83 :: #type proc "c" (
	descriptorSet: ^Descriptor_Set,
	#by_ptr descriptorSetCopyDesc: Descriptor_Set_Copy_Desc,
)
AllocateDescriptorSets_func_ptr_anon_84 :: #type proc "c" (
	descriptorPool: ^Descriptor_Pool,
	pipelineLayout: ^Pipeline_Layout,
	setIndex: u32,
	descriptorSets: [^]^Descriptor_Set,
	instanceNum: u32,
	variableDescriptorNum: u32,
) -> Result
ResetDescriptorPool_func_ptr_anon_85 :: #type proc "c" (descriptorPool: ^Descriptor_Pool)
ResetCommandAllocator_func_ptr_anon_86 :: #type proc "c" (commandAllocator: ^Command_Allocator)
MapBuffer_func_ptr_anon_87 :: #type proc "c" (buffer: ^Buffer, offset: u64, size: u64) -> rawptr
UnmapBuffer_func_ptr_anon_88 :: #type proc "c" (buffer: ^Buffer)
SetDeviceDebugName_func_ptr_anon_89 :: #type proc "c" (device: ^Device, name: cstring)
SetFenceDebugName_func_ptr_anon_90 :: #type proc "c" (fence: ^Fence, name: cstring)
SetDescriptorDebugName_func_ptr_anon_91 :: #type proc "c" (descriptor: ^Descriptor, name: cstring)
SetPipelineDebugName_func_ptr_anon_92 :: #type proc "c" (pipeline: ^Pipeline, name: cstring)
SetCommandBufferDebugName_func_ptr_anon_93 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
	name: cstring,
)
SetBufferDebugName_func_ptr_anon_94 :: #type proc "c" (buffer: ^Buffer, name: cstring)
SetTextureDebugName_func_ptr_anon_95 :: #type proc "c" (texture: ^Texture, name: cstring)
SetCommandQueueDebugName_func_ptr_anon_96 :: #type proc "c" (
	commandQueue: ^Command_Queue,
	name: cstring,
)
SetCommandAllocatorDebugName_func_ptr_anon_97 :: #type proc "c" (
	commandAllocator: ^Command_Allocator,
	name: cstring,
)
SetDescriptorPoolDebugName_func_ptr_anon_98 :: #type proc "c" (
	descriptorPool: ^Descriptor_Pool,
	name: cstring,
)
SetPipelineLayoutDebugName_func_ptr_anon_99 :: #type proc "c" (
	pipelineLayout: ^Pipeline_Layout,
	name: cstring,
)
SetQueryPoolDebugName_func_ptr_anon_100 :: #type proc "c" (queryPool: ^Query_Pool, name: cstring)
SetDescriptorSetDebugName_func_ptr_anon_101 :: #type proc "c" (
	descriptorSet: ^Descriptor_Set,
	name: cstring,
)
SetMemoryDebugName_func_ptr_anon_102 :: #type proc "c" (memory: ^Memory, name: cstring)
GetDeviceNativeObject_func_ptr_anon_103 :: #type proc "c" (device: ^Device) -> rawptr
GetCommandBufferNativeObject_func_ptr_anon_104 :: #type proc "c" (
	commandBuffer: ^Command_Buffer,
) -> rawptr
GetBufferNativeObject_func_ptr_anon_105 :: #type proc "c" (buffer: ^Buffer) -> u64
GetTextureNativeObject_func_ptr_anon_106 :: #type proc "c" (texture: ^Texture) -> u64
GetDescriptorNativeObject_func_ptr_anon_107 :: #type proc "c" (descriptor: ^Descriptor) -> u64
Core_Interface :: struct {
	GetDeviceDesc:                GetDeviceDesc_func_ptr_anon_0,
	GetBufferDesc:                GetBufferDesc_func_ptr_anon_1,
	GetTextureDesc:               GetTextureDesc_func_ptr_anon_2,
	GetFormatSupport:             GetFormatSupport_func_ptr_anon_3,
	GetQuerySize:                 GetQuerySize_func_ptr_anon_4,
	GetBufferMemoryDesc:          GetBufferMemoryDesc_func_ptr_anon_5,
	GetTextureMemoryDesc:         GetTextureMemoryDesc_func_ptr_anon_6,
	GetCommandQueue:              GetCommandQueue_func_ptr_anon_7,
	CreateCommandAllocator:       CreateCommandAllocator_func_ptr_anon_8,
	CreateCommandBuffer:          CreateCommandBuffer_func_ptr_anon_9,
	CreateDescriptorPool:         CreateDescriptorPool_func_ptr_anon_10,
	CreateBuffer:                 CreateBuffer_func_ptr_anon_11,
	CreateTexture:                CreateTexture_func_ptr_anon_12,
	CreateBufferView:             CreateBufferView_func_ptr_anon_13,
	CreateTexture1DView:          CreateTexture1DView_func_ptr_anon_14,
	CreateTexture2DView:          CreateTexture2DView_func_ptr_anon_15,
	CreateTexture3DView:          CreateTexture3DView_func_ptr_anon_16,
	CreateSampler:                CreateSampler_func_ptr_anon_17,
	CreatePipelineLayout:         CreatePipelineLayout_func_ptr_anon_18,
	CreateGraphicsPipeline:       CreateGraphicsPipeline_func_ptr_anon_19,
	CreateComputePipeline:        CreateComputePipeline_func_ptr_anon_20,
	CreateQueryPool:              CreateQueryPool_func_ptr_anon_21,
	CreateFence:                  CreateFence_func_ptr_anon_22,
	DestroyCommandAllocator:      DestroyCommandAllocator_func_ptr_anon_23,
	DestroyCommandBuffer:         DestroyCommandBuffer_func_ptr_anon_24,
	DestroyDescriptorPool:        DestroyDescriptorPool_func_ptr_anon_25,
	DestroyBuffer:                DestroyBuffer_func_ptr_anon_26,
	DestroyTexture:               DestroyTexture_func_ptr_anon_27,
	DestroyDescriptor:            DestroyDescriptor_func_ptr_anon_28,
	DestroyPipelineLayout:        DestroyPipelineLayout_func_ptr_anon_29,
	DestroyPipeline:              DestroyPipeline_func_ptr_anon_30,
	DestroyQueryPool:             DestroyQueryPool_func_ptr_anon_31,
	DestroyFence:                 DestroyFence_func_ptr_anon_32,
	AllocateMemory:               AllocateMemory_func_ptr_anon_33,
	BindBufferMemory:             BindBufferMemory_func_ptr_anon_34,
	BindTextureMemory:            BindTextureMemory_func_ptr_anon_35,
	FreeMemory:                   FreeMemory_func_ptr_anon_36,
	BeginCommandBuffer:           BeginCommandBuffer_func_ptr_anon_37,
	CmdSetDescriptorPool:         CmdSetDescriptorPool_func_ptr_anon_38,
	CmdSetPipelineLayout:         CmdSetPipelineLayout_func_ptr_anon_39,
	CmdSetDescriptorSet:          CmdSetDescriptorSet_func_ptr_anon_40,
	CmdSetRootConstants:          CmdSetRootConstants_func_ptr_anon_41,
	CmdSetRootDescriptor:         CmdSetRootDescriptor_func_ptr_anon_42,
	CmdSetPipeline:               CmdSetPipeline_func_ptr_anon_43,
	CmdBarrier:                   CmdBarrier_func_ptr_anon_44,
	CmdSetIndexBuffer:            CmdSetIndexBuffer_func_ptr_anon_45,
	CmdSetVertexBuffers:          CmdSetVertexBuffers_func_ptr_anon_46,
	CmdSetViewports:              CmdSetViewports_func_ptr_anon_47,
	CmdSetScissors:               CmdSetScissors_func_ptr_anon_48,
	CmdSetStencilReference:       CmdSetStencilReference_func_ptr_anon_49,
	CmdSetDepthBounds:            CmdSetDepthBounds_func_ptr_anon_50,
	CmdSetBlendConstants:         CmdSetBlendConstants_func_ptr_anon_51,
	CmdSetSampleLocations:        CmdSetSampleLocations_func_ptr_anon_52,
	CmdSetShadingRate:            CmdSetShadingRate_func_ptr_anon_53,
	CmdSetDepthBias:              CmdSetDepthBias_func_ptr_anon_54,
	CmdBeginRendering:            CmdBeginRendering_func_ptr_anon_55,
	CmdClearAttachments:          CmdClearAttachments_func_ptr_anon_56,
	CmdDraw:                      CmdDraw_func_ptr_anon_57,
	CmdDrawIndexed:               CmdDrawIndexed_func_ptr_anon_58,
	CmdDrawIndirect:              CmdDrawIndirect_func_ptr_anon_59,
	CmdDrawIndexedIndirect:       CmdDrawIndexedIndirect_func_ptr_anon_60,
	CmdEndRendering:              CmdEndRendering_func_ptr_anon_61,
	CmdDispatch:                  CmdDispatch_func_ptr_anon_62,
	CmdDispatchIndirect:          CmdDispatchIndirect_func_ptr_anon_63,
	CmdCopyBuffer:                CmdCopyBuffer_func_ptr_anon_64,
	CmdCopyTexture:               CmdCopyTexture_func_ptr_anon_65,
	CmdResolveTexture:            CmdResolveTexture_func_ptr_anon_66,
	CmdUploadBufferToTexture:     CmdUploadBufferToTexture_func_ptr_anon_67,
	CmdReadbackTextureToBuffer:   CmdReadbackTextureToBuffer_func_ptr_anon_68,
	CmdClearStorageBuffer:        CmdClearStorageBuffer_func_ptr_anon_69,
	CmdClearStorageTexture:       CmdClearStorageTexture_func_ptr_anon_70,
	CmdResetQueries:              CmdResetQueries_func_ptr_anon_71,
	CmdBeginQuery:                CmdBeginQuery_func_ptr_anon_72,
	CmdEndQuery:                  CmdEndQuery_func_ptr_anon_73,
	CmdCopyQueries:               CmdCopyQueries_func_ptr_anon_74,
	CmdBeginAnnotation:           CmdBeginAnnotation_func_ptr_anon_75,
	CmdEndAnnotation:             CmdEndAnnotation_func_ptr_anon_76,
	EndCommandBuffer:             EndCommandBuffer_func_ptr_anon_77,
	QueueSubmit:                  QueueSubmit_func_ptr_anon_78,
	Wait:                         Wait_func_ptr_anon_79,
	GetFenceValue:                GetFenceValue_func_ptr_anon_80,
	UpdateDescriptorRanges:       UpdateDescriptorRanges_func_ptr_anon_81,
	UpdateDynamicConstantBuffers: UpdateDynamicConstantBuffers_func_ptr_anon_82,
	CopyDescriptorSet:            CopyDescriptorSet_func_ptr_anon_83,
	AllocateDescriptorSets:       AllocateDescriptorSets_func_ptr_anon_84,
	ResetDescriptorPool:          ResetDescriptorPool_func_ptr_anon_85,
	ResetCommandAllocator:        ResetCommandAllocator_func_ptr_anon_86,
	MapBuffer:                    MapBuffer_func_ptr_anon_87,
	UnmapBuffer:                  UnmapBuffer_func_ptr_anon_88,
	SetDeviceDebugName:           SetDeviceDebugName_func_ptr_anon_89,
	SetFenceDebugName:            SetFenceDebugName_func_ptr_anon_90,
	SetDescriptorDebugName:       SetDescriptorDebugName_func_ptr_anon_91,
	SetPipelineDebugName:         SetPipelineDebugName_func_ptr_anon_92,
	SetCommandBufferDebugName:    SetCommandBufferDebugName_func_ptr_anon_93,
	SetBufferDebugName:           SetBufferDebugName_func_ptr_anon_94,
	SetTextureDebugName:          SetTextureDebugName_func_ptr_anon_95,
	SetCommandQueueDebugName:     SetCommandQueueDebugName_func_ptr_anon_96,
	SetCommandAllocatorDebugName: SetCommandAllocatorDebugName_func_ptr_anon_97,
	SetDescriptorPoolDebugName:   SetDescriptorPoolDebugName_func_ptr_anon_98,
	SetPipelineLayoutDebugName:   SetPipelineLayoutDebugName_func_ptr_anon_99,
	SetQueryPoolDebugName:        SetQueryPoolDebugName_func_ptr_anon_100,
	SetDescriptorSetDebugName:    SetDescriptorSetDebugName_func_ptr_anon_101,
	SetMemoryDebugName:           SetMemoryDebugName_func_ptr_anon_102,
	GetDeviceNativeObject:        GetDeviceNativeObject_func_ptr_anon_103,
	GetCommandBufferNativeObject: GetCommandBufferNativeObject_func_ptr_anon_104,
	GetBufferNativeObject:        GetBufferNativeObject_func_ptr_anon_105,
	GetTextureNativeObject:       GetTextureNativeObject_func_ptr_anon_106,
	GetDescriptorNativeObject:    GetDescriptorNativeObject_func_ptr_anon_107,
}

Message :: enum u8 {
	Info,
	Warning,
	Error,
}

Allocation_Callbacks :: struct {
	Allocate:   proc "c" (user_data: rawptr, size: u64, alignment: u64) -> rawptr,
	Reallocate: proc "c" (user_data: rawptr, ptr: rawptr, size: u64, alignment: u64) -> rawptr,
	Free:       proc "c" (user_data: rawptr, ptr: rawptr),
	user_arg:   rawptr,
}

Callback_Interface :: struct {
	MessageCallback: proc "c" (
		level: Message,
		file: cstring,
		line: u32,
		message: cstring,
		user_data: rawptr,
	),
	AbortExecution:  proc "c" (user_data: rawptr),
	user_arg:        rawptr,
}

SPIRV_Binding_Offsets :: struct {
	sampler_offset:                    u32,
	texture_offset:                    u32,
	constant_buffer_offset:            u32,
	storage_texture_and_buffer_offset: u32,
}

VK_Extensions :: struct {
	instance_extensions:    [^]cstring,
	instance_extension_num: u32,
	device_extensions:      [^]cstring,
	device_extension_num:   u32,
}

Device_Creation_Desc :: struct {
	adapter_desc:                           ^Adapter_Desc,
	callback_interface:                     Callback_Interface,
	allocation_callbacks:                   Allocation_Callbacks,
	spirv_binding_offsets:                  SPIRV_Binding_Offsets,
	vk_extensions:                          VK_Extensions,
	graphics_api:                           Graphics_API,
	shader_ext_register:                    u32,
	shader_ext_space:                       u32,
	enable_validation:                      bool,
	enable_graphics_api_validation:         bool,
	enable_d3d12_draw_parameters_emulation: bool,
	enable_d3d11_command_buffer_emulation:  bool,
	disable_vk_ray_tracing:                 bool,
	disable3rd_party_allocation_callbacks:  bool,
}

Swap_Chain_Format :: enum u8 {
	BT709_G10_16BIT,
	BT709_G22_8BIT,
	BT709_G22_10BIT,
	BT2020_G2084_10BIT,
}

Windows_Window :: struct {
	hwnd: rawptr,
}

X11_Window :: struct {
	display: rawptr,
	window:  rawptr,
}

Wayland_Window :: struct {
	display: rawptr,
	surface: rawptr,
}

Metal_Window :: struct {
	ca_metal_layer: rawptr,
}

Window :: struct {
	windows: Windows_Window,
	x11:     X11_Window,
	wayland: Wayland_Window,
	metal:   Metal_Window,
}

Swap_Chain_Desc :: struct {
	window:            Window,
	command_queue:     ^Command_Queue,
	width, height:     dim,
	texture_num:       u8,
	format:            Swap_Chain_Format,
	vsync_interval:    u8,
	queue_frame_num:   u8,
	waitable:          bool,
	allow_low_latency: bool,
}

Chromaticity_Coords :: struct {
	x, y: f32,
}

Display_Desc :: struct {
	red_primary:                  Chromaticity_Coords,
	green_primary:                Chromaticity_Coords,
	blue_primary:                 Chromaticity_Coords,
	white_point:                  Chromaticity_Coords,
	max_luminance, min_luminance: f32,
	max_full_frame_luminance:     f32,
	sdr_luminance:                f32,
	is_hdr:                       bool,
}

Swap_Chain :: distinct rawptr

SWAPCHAIN_SEMAPHORE :: ~u64(0)

Swap_Chain_Interface :: struct {
	CreateSwapChain:             proc "c" (
		device: ^Device,
		#by_ptr desc: Swap_Chain_Desc,
		swapchain: ^^Swap_Chain,
	) -> Result,
	DestroySwapChain:            proc "c" (swapchain: ^Swap_Chain),
	SetSwapChainDebugName:       proc "c" (swapchain: ^Swap_Chain, name: cstring),
	GetSwapChainTextures:        proc "c" (
		swapchain: ^Swap_Chain,
		texture_num: ^u32,
	) -> [^]^Texture,
	AcquireNextSwapChainTexture: proc "c" (swapchain: ^Swap_Chain) -> u32,
	WaitForPresent:              proc "c" (swapchain: ^Swap_Chain) -> Result,
	QueuePresent:                proc "c" (swapchain: ^Swap_Chain) -> Result,
	GetDisplayDesc:              proc "c" (
		swapchain: ^Swap_Chain,
		#by_ptr desc: Display_Desc,
	) -> Result,
}

Format_Bits :: bit_field u64 {
	stride:        u8   | 6,
	block_width:   u8   | 4,
	block_height:  u8   | 4,
	is_bgr:        bool | 1,
	is_compressed: bool | 1,
	is_depth:      bool | 1,
	is_exp_shared: bool | 1,
	is_float:      bool | 1,
	is_packed:     bool | 1,
	is_integer:    bool | 1,
	is_norm:       bool | 1,
	is_signed:     bool | 1,
	is_srgb:       bool | 1,
	is_stencil:    bool | 1,
}

Format_Props :: struct {
	name:       cstring,
	format:     Format,
	red_bits:   u8,
	green_bits: u8,
	blue_bits:  u8,
	alpha_bits: u8,
	using _:    Format_Bits,
}

when ODIN_OS == .Windows {
	when ODIN_ARCH == .amd64 {
		foreign import nri {"./lib/x64-windows.lib", "system:dxgi.lib", "system:dxguid.lib", "system:d3d12.lib", "system:d3d11.lib", "system:User32.lib"}
	} else when ODIN_ARCH == .arm64 {
		foreign import nri "./lib/arm64-windows.lib"
	} else do #panic("Unsupported architecture")
} else when ODIN_OS == .Darwin {
	when ODIN_ARCH == .arm64 {
		foreign import nri "./lib/libarm64-macos.a"
	} else do #panic("Unsupported architecture")
} else when ODIN_OS == .Linux {
	when ODIN_ARCH == .amd64 {
		foreign import nri "./lib/libx64-linux.a"
	} else when ODIN_ARCH == .arm64 {
		foreign import nri "./lib/libarm64-linux.a"
	} else do #panic("Unsupported architecture")
} else do #panic("Unsupported OS")

@(link_prefix = "nri")
foreign nri {
	GetInterface :: proc "c" (device: ^Device, name: cstring, size: u64, ptr: rawptr) -> Result ---
	EnumerateAdapters :: proc "c" (adapter_descs: [^]Adapter_Desc, adapter_desc_num: ^u32) -> Result ---
	CreateDevice :: proc "c" (#by_ptr device_creation_desc: Device_Creation_Desc, device: ^^Device) -> Result ---
	DestroyDevice :: proc "c" (device: ^Device) -> Result ---
	ReportLiveObjects :: proc "c" () ---
	GetFormatProps :: proc "c" (format: Format) -> ^Format_Props ---
}
