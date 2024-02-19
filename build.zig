const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Project configure options
    const enable_shared = b.option(bool, "enable-shared", "Create a shared lib instead of a static lib. Default: false") orelse false;
    _ = enable_shared;
    const enable_float = b.option(bool, "enable-float", "Enable single precision instead of default double precision. Default: false") orelse false;
    const enable_long_double = b.option(bool, "enable-long-double", "Enable long double precision instead of default double precision. Default: false") orelse false;
    const enable_quad_precision = b.option(bool, "enable-quad-precision", "Enable quad precision using the __float128 type instead of default double precision. Default: false") orelse false;
    const enable_threads = b.option(bool, "enable-threads", "Enable compilation of a separate FFTW3 threads library. Default: false") orelse false;
    _ = enable_threads;
    const enable_openmp = b.option(bool, "enable-openmp", "Like -Denable-threads, but uses OpenMP for multiparallelism in main lib. Default: false") orelse false;
    _ = enable_openmp;
    const with_combined_threads = b.option(bool, "with-combined-threads", "Enable threads in the main FFTW3 library. Default: false") orelse false;
    _ = with_combined_threads;
    const enable_mpi = b.option(bool, "enable-mpi", "Enable compilation of the FFTW3 MPI library.") orelse false;
    _ = enable_mpi;
    const disable_fortran = b.option(bool, "disable-fortran", "Disables inclusion of legacy Fortran wrappers. Default: true") orelse true;
    _ = disable_fortran;
    const with_g77_wrappers = b.option(bool, "with-g77-wrappers", "Enables wrappers compatible with the g77 compiler. Default: false") orelse false;
    _ = with_g77_wrappers;
    const with_slow_timer = b.option(bool, "with-slow-timer", "Disables the use of cycle counters. Generally should not be used. Default: false") orelse false;
    _ = with_slow_timer;

    // SIMD options
    //const enable_sse
    //const enable_sse2
    //const enable_avx
    //const enable_avx2
    //const enable_avx512
    //const enable_avx128_fma
    //const enable_kcvi
    //const enable_altivec
    //const enable_vsx
    //const enable_neon
    //const enable_generic_simd128
    //const enable_generic_simd256

    if (enable_float and enable_long_double) @panic("-Denable-float and -Denable-long-double cannot both be enabled.");
    if (enable_float and enable_quad_precision) @panic("-Denable-float and -Denable-quad-precision cannot both be enabled.");
    if (enable_long_double and enable_quad_precision) @panic("-Denable-long-double and -Denable-quad-precision cannot both be enabled.");

    const fftw3_lib = b.dependency("fftw3", .{});
    const fftw3_config_h_template = fftw3_lib.path("config.h.in");
    _ = fftw3_config_h_template;

    const dylib = b.addDynamicLibrary(.{
        .name = "fftw3-zig-build",
        .root_source_file = .{ .path = "src/root.zig" },
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(dylib);

    const lib_unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/root.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}

// TODO: Update these to be more portable
const ConfigHeader = std.Build.Step.ConfigHeader;
const FFTW3ConfigOptions = struct {
    ARCH_PREFERS_FMA: ConfigHeader.Value = .{.undef},
    BENCHFFT_LDOUBLE: ConfigHeader.Value = .{.undef},
    BENCHFFT_QUAD: ConfigHeader.Value = .{.undef},
    BENCHFFT_SINGLE: ConfigHeader.Value = .{.undef},
    CRAY_STACKSEG_END: ConfigHeader.Value = .{.undef},
    C_ALLOCA: ConfigHeader.Value = .{.undef},
    DISABLE_FORTRAN: ConfigHeader.Value = .{.undef},
    F77_DUMMY_MAIN: ConfigHeader.Value = .{.undef},
    F77_FUNC: ConfigHeader.Value = .{.undef},
    F77_FUNC_: ConfigHeader.Value = .{.undef},
    F77_FUNC_EQUIV: ConfigHeader.Value = .{.undef},
    FC_DUMMY_MAIN_EQ_F77: ConfigHeader.Value = .{.undef},
    FFTW_CC: ConfigHeader.Value = .{ .string = "zig cc -O3 -fomit-frame-pointer -mtune=native -fstrict-aliasing" },
    FFTW_DEBUG: ConfigHeader.Value,
    FFTW_ENABLE_ALLOCA: ConfigHeader.Value = .{ .ident = "1" },
    FFTW_LDOUBLE: ConfigHeader.Value = .{.undef},
    FFTW_QUAD: ConfigHeader.Value = .{.undef},
    FFTW_RANDOM_ESTIMATOR: ConfigHeader.Value,
    FFTW_SINGLE: ConfigHeader.Value,
    HAVE_ABORT: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_ALLOCA: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_ALLOCA_H: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_ALTIVEC: ConfigHeader.Value,
    HAVE_ALTIVEC_H: ConfigHeader.Value,
    HAVE_ARMV7A_CNTVCT: ConfigHeader.Value = .{.undef},
    HAVE_ARMV7A_PMCCNTR: ConfigHeader.Value = .{.undef},
    HAVE_ARMV8_CNTVCT_EL0: ConfigHeader.Value = .{.undef},
    HAVE_ARMV8_PMCCNTR_EL0: ConfigHeader.Value = .{.undef},
    HAVE_AVX: ConfigHeader.Value,
    HAVE_AVX2: ConfigHeader.Value,
    HAVE_AVX512: ConfigHeader.Value,
    HAVE_AVX_128_FMA: ConfigHeader.Value,
    HAVE_BSDGETTIMEOFDAY: ConfigHeader.Value = .{.undef},
    HAVE_CLOCK_GETTIME: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_COSL: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_DECL_COSL: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_DECL_COSQ: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_DECL_DRAND48: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_DECL_MEMALIGN: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_DECL_POSIX_MEMALIGN: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_DECL_SINL: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_DECL_SINQ: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_DECL_SRAND48: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_DLFCN_H: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_DOPRNT: ConfigHeader.Value = .{.undef},
    HAVE_DRAND48: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_FCNTL_H: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_FENV_H: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_GENERIC_SIMD128: ConfigHeader.Value,
    HAVE_GENERIC_SIMD256: ConfigHeader.Value,
    HAVE_GETHRTIME: ConfigHeader.Value = .{.undef},
    HAVE_GETPAGESIZE: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_GETTIMEOFDAY: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_HRTIME_T: ConfigHeader.Value = .{.undef},
    HAVE_INTTYPES_H: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_ISNAN: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_KCVI: ConfigHeader.Value = .{.undef},
    HAVE_LIBM: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_LIBQUADMATH: ConfigHeader.Value = .{.undef},
    HAVE_LIMITS_H: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_LONG_DOUBLE: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_MACH_ABSOLUTE_TIME: ConfigHeader.Value = .{.undef},
    HAVE_MALLOC_H: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_MEMALIGN: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_MEMMOVE: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_MEMORY_H: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_MEMSET: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_MIPS_ZBUS_TIMER: ConfigHeader.Value = .{.undef},
    HAVE_MPI: ConfigHeader.Value = .{.undef},
    HAVE_NEON: ConfigHeader.Value = .{.undef},
    HAVE_OPENMP: ConfigHeader.Value = .{.undef},
    HAVE_POSIX_MEMALIGN: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_PTHREAD: ConfigHeader.Value = .{.undef},
    HAVE_PTRDIFF_T: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_READ_REAL_TIME: ConfigHeader.Value = .{.undef},
    HAVE_SINL: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_SNPRINTF: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_SQRT: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_SSE2: ConfigHeader.Value = .{.undef},
    HAVE_STDDEF_H: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_STDINT_H: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_STDLIB_H: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_STRCHR: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_STRINGS_H: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_STRING_H: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_SYSCTL: ConfigHeader.Value = .{.undef},
    HAVE_SYS_STAT_H: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_SYS_TIME_H: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_SYS_TYPES_H: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_TANL: ConfigHeader.Value = .{.undef},
    HAVE_THREADS: ConfigHeader.Value = .{.undef},
    HAVE_TIME_BASE_TO_TIME: ConfigHeader.Value = .{.undef},
    HAVE_UINTPTR_T: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_UNISTD_H: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_VPRINTF: ConfigHeader.Value = .{ .ident = "1" },
    HAVE_VSX: ConfigHeader.Value = .{.undef},
    HAVE__MM_FREE: ConfigHeader.Value = .{.undef},
    HAVE__MM_MALLOC: ConfigHeader.Value = .{.undef},
    HAVE__RTC: ConfigHeader.Value = .{.undef},
    LT_OBJDIR: ConfigHeader.Value = .{ .string = ".libs/" },
    PACKAGE: ConfigHeader.Value = .{ .string = "fftw" },
    PACKAGE_BUGREPORT: ConfigHeader.Value = .{ .string = "fftw@fftw.org" },
    PACKAGE_NAME: ConfigHeader.Value = .{ .string = "fftw" },
    PACKAGE_STRING: ConfigHeader.Value = .{ .string = "fftw 3.3.10" },
    PACKAGE_TARNAME: ConfigHeader.Value = .{ .string = "fftw" },
    PACKAGE_URL: ConfigHeader.Value = .{ .string = "https://www.fftw.org/" },
    PACKAGE_VERSION: ConfigHeader.Value = .{ .string = "3.3.10" },
    PTHREAD_CREATE_JOINABLE: ConfigHeader.Value = .{.undef},
    SIZEOF_DOUBLE: ConfigHeader.Value,
    SIZEOF_FFTW_R2R_KIND: ConfigHeader.Value,
    SIZEOF_FLOAT: ConfigHeader.Value,
    SIZEOF_INT: ConfigHeader.Value,
    SIZEOF_LONG: ConfigHeader.Value,
    SIZEOF_LONG_LONG: ConfigHeader.Value,
    SIZEOF_MPI_FINT: ConfigHeader.Value = .{.undef},
    SIZEOF_PTRDIFF_T: ConfigHeader.Value,
    SIZEOF_SIZE_T: ConfigHeader.Value,
    SIZEOF_UNSIGNED_INT: ConfigHeader.Value,
    SIZEOF_UNSIGNED_LONG: ConfigHeader.Value,
    SIZEOF_UNSIGNED_LONG_LONG: ConfigHeader.Value,
    SIZEOF_VOID_P: ConfigHeader.Value = .{.undef},
    STACK_DIRECTION: ConfigHeader.Value = .{.undef},
    STDC_HEADERS: ConfigHeader.Value = .{ .ident = "1" },
    TIME_WITH_SYS_TIME: ConfigHeader.Value = .{ .ident = "1" },
    USING_POSIX_THREADS: ConfigHeader.Value = .{.undef},
    VERSION: ConfigHeader.Value = .{ .string = "3.3.10" },
    WINDOWS_F77_MANGLING: ConfigHeader.Value = .{.undef},
    WITH_G77_WRAPPERS: ConfigHeader.Value = .{ .ident = "1" },
    WITH_OUR_MALLOC: ConfigHeader.Value = .{.undef},
    WITH_SLOW_TIMER: ConfigHeader.Value = .{.undef},
    _UINT32_T: ConfigHeader.Value = .{.undef},
    _UINT64_T: ConfigHeader.Value = .{.undef},
    @"const": ConfigHeader.Value = .{.undef},
    @"inline": ConfigHeader.Value = .{.undef},
    size_t: ConfigHeader.Value = .{.undef},
    uint32_t: ConfigHeader.Value = .{.undef},
    uint64_t: ConfigHeader.Value = .{.undef},

    pub const ConfigOptions = struct {
        enable_shared: bool,
        enable_float: bool,
        enable_long_double: bool,
        enable_quad_precision: bool,
        enable_threads: bool,
        enable_openmp: bool,
        with_combined_threads: bool,
        enable_mpi: bool,
        disable_fortran: bool,
        with_g77_wrappers: bool,
        with_slow_timer: bool,
        enable_sse: ?bool,
        enable_sse2: ?bool,
        enable_avx: ?bool,
        enable_avx2: ?bool,
        enable_avx512: ?bool,
        enable_avx128_fma: ?bool,
        enable_kcvi: ?bool,
        enable_altivec: ?bool,
        enable_vsx: ?bool,
        enable_neon: ?bool,
        enable_generic_simd128: ?bool,
        enable_generic_simd256: ?bool,
    };
    pub fn init(user_config: ConfigOptions, target: std.Target, optimize: std.builtin.OptimizeMode) FFTW3ConfigOptions {
        _ = user_config;
        const features = SIMDFeatures.detect(target);
        _ = features;
        const is_debug = optimize == .Debug;
        return FFTW3ConfigOptions{
            .FFTW_DEBUG = if (is_debug) .{.defined} else .{.undef},
            .FFTW_RANDOM_ESTIMATOR = if (is_debug) .{.defined} else .{.undef},
            //.HAVE_ALTIVEC,
            //.HAVE_ALTIVEC_H,
            //.HAVE_AVX,
            //.HAVE_AVX2,
            //.HAVE_AVX512,
            //.HAVE_AVX_128_FMA,
            //.HAVE_GENERIC_SIMD128,
            //.HAVE_GENERIC_SIMD256,
            .SIZEOF_DOUBLE = target.c_type_byte_size(.double),
            //.SIZEOF_FFTW_R2R_KIND, //FIXME
            .SIZEOF_FLOAT = target.c_type_byte_size(.float),
            .SIZEOF_INT = target.c_type_byte_size(.int),
            .SIZEOF_LONG = target.c_type_byte_size(.long),
            .SIZEOF_LONG_LONG = target.c_type_byte_size(.longlong),
            //.SIZEOF_PTRDIFF_T = target.c_type_byte_size(),
            //.SIZEOF_SIZE_T = target.c_type_byte_size(),
            .SIZEOF_UNSIGNED_INT = target.c_type_byte_size(.uint),
            .SIZEOF_UNSIGNED_LONG = target.c_type_byte_size(.ulong),
            .SIZEOF_UNSIGNED_LONG_LONG = target.c_type_byte_size(.ulonglong),
        };
    }

    const SIMDFeatures = struct {
        has_sse: bool = false,
        has_sse2: bool = false,
        has_avx: bool = false,
        has_avx2: bool = false,
        has_avx512: bool = false,
        has_avx128_fma: bool = false,
        has_kcvi: bool = false,
        has_altivec: bool = false,
        has_vsx: bool = false,
        has_neon: bool = false,
        has_generic_simd128: bool = false,
        has_generic_simd256: bool = false,

        fn detect(target: std.Target) SIMDFeatures {
            const features = target.cpu.features;
            return .{
                .has_sse = features.featureSetHas(.sse),
                .has_sse2 = features.featureSetHas(.sse2),
                .has_avx = features.featureSetHas(.avx),
                .has_avx2 = features.featureSetHas(.avx2),
                .has_avx512 = features.featureSetHas(.avx512f),
                .has_avx128_fma = features.featureSetHas(.fma4),
                .has_kcvi = false, // TODO: detectable?
                .has_altivec = features.featureSetHas(.altivec),
                .has_vsx = features.featureSetHas(.vsx),
                .has_neon = features.featureSetHas(.neon),
                .has_generic_simd128 = true, // TODO: detectable?
                .has_generic_simd256 = true, // TODO: detectable?
            };
        }
    };
};
