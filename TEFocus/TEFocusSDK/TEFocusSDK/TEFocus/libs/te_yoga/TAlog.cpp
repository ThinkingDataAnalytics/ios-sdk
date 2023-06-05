
#include "TAlog.h"

#include "TAYoga.h"
#include "TAYGConfig.h"
#include "TAYGNode.h"

namespace thinkingdatalayout {
namespace ta_yoga {
namespace detail {

namespace {

void vlog(
    TAYGConfig* config,
    TAYGNode* node,
    TAYGLogLevel level,
    void* context,
    const char* format,
    va_list args) {
  TAYGConfig* logConfig = config != nullptr ? config : TAYGConfigGetDefault();
  logConfig->log(logConfig, node, level, context, format, args);
}
} // namespace

TA_YOGA_EXPORT void TALog::log(
    TAYGNode* node,
    TAYGLogLevel level,
    void* context,
    const char* format,
    ...) noexcept {
  va_list args;
  va_start(args, format);
  vlog(
      node == nullptr ? nullptr : node->getConfig(),
      node,
      level,
      context,
      format,
      args);
  va_end(args);
}

void TALog::log(
    TAYGConfig* config,
    TAYGLogLevel level,
    void* context,
    const char* format,
    ...) noexcept {
  va_list args;
  va_start(args, format);
  vlog(config, nullptr, level, context, format, args);
  va_end(args);
}

} // namespace detail
} // namespace ta_yoga
} // namespace thinkingdatalayout
