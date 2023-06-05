
#pragma once

#include "TAYGEnums.h"

struct TAYGNode;
struct TAYGConfig;

namespace thinkingdatalayout {
namespace ta_yoga {

namespace detail {

struct TALog {
  static void log(
      TAYGNode* node,
      TAYGLogLevel level,
      void*,
      const char* message,
      ...) noexcept;

  static void log(
      TAYGConfig* config,
      TAYGLogLevel level,
      void*,
      const char* format,
      ...) noexcept;
};

} // namespace detail
} // namespace ta_yoga
} // namespace thinkingdatalayout
