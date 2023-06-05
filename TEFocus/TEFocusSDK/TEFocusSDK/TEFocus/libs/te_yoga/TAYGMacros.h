
#pragma once

#ifdef __cplusplus
#define TA_YG_EXTERN_C_BEGIN extern "C" {
#define TA_YG_EXTERN_C_END }
#else
#define TA_YG_EXTERN_C_BEGIN
#define TA_YG_EXTERN_C_END
#endif

#ifdef _WINDLL
#define WIN_EXPORT __declspec(dllexport)
#else
#define WIN_EXPORT
#endif

#ifndef TA_YOGA_EXPORT
#ifdef _MSC_VER
#define TA_YOGA_EXPORT
#else
#define TA_YOGA_EXPORT __attribute__((visibility("default")))
#endif
#endif

#ifdef NS_ENUM
// Cannot use NSInteger as NSInteger has a different size than int (which is the
// default type of a enum). Therefor when linking the TAYoga C library into obj-c
// the header is a missmatch for the TAYoga ABI.
#define TA_YG_ENUM_BEGIN(name) NS_ENUM(int, name)
#define TA_YG_ENUM_END(name)
#else
#define TA_YG_ENUM_BEGIN(name) enum name
#define TA_YG_ENUM_END(name) name
#endif

#ifdef __GNUC__
#define TA_YG_DEPRECATED __attribute__((deprecated))
#elif defined(_MSC_VER)
#define TA_YG_DEPRECATED __declspec(deprecated)
#elif __cplusplus >= 201402L
#if defined(__has_cpp_attribute)
#if __has_cpp_attribute(deprecated)
#define TA_YG_DEPRECATED [[deprecated]]
#endif
#endif
#endif
