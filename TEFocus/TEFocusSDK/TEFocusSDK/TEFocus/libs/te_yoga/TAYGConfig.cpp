
#include "TAYGConfig.h"

TAYGConfig::TAYGConfig(TAYGLogger logger) : cloneNodeCallback_{nullptr} {
  logger_.noContext = logger;
  loggerUsesContext_ = false;
}

void TAYGConfig::log(
    TAYGConfig* config,
    TAYGNode* node,
    TAYGLogLevel logLevel,
    void* logContext,
    const char* format,
    va_list args) {
  if (loggerUsesContext_) {
    logger_.withContext(config, node, logLevel, logContext, format, args);
  } else {
    logger_.noContext(config, node, logLevel, format, args);
  }
}

TAYGNodeRef TAYGConfig::cloneNode(
    TAYGNodeRef node,
    TAYGNodeRef owner,
    int childIndex,
    void* cloneContext) {
  TAYGNodeRef clone = nullptr;
  if (cloneNodeCallback_.noContext != nullptr) {
    clone = cloneNodeUsesContext_
        ? cloneNodeCallback_.withContext(node, owner, childIndex, cloneContext)
        : cloneNodeCallback_.noContext(node, owner, childIndex);
  }
  if (clone == nullptr) {
    clone = TAYGNodeClone(node);
  }
  return clone;
}
