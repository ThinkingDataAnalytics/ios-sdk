

#pragma once
#include "TAYoga-internal.h"
#include "TAYoga.h"

struct TA_YOGA_EXPORT TAYGConfig {
  using LogWithContextFn = int (*)(
      TAYGConfigRef config,
      TAYGNodeRef node,
      TAYGLogLevel level,
      void* context,
      const char* format,
      va_list args);
  using CloneWithContextFn = TAYGNodeRef (*)(
      TAYGNodeRef node,
      TAYGNodeRef owner,
      int childIndex,
      void* cloneContext);

private:
  union {
    CloneWithContextFn withContext;
    TAYGCloneNodeFunc noContext;
  } cloneNodeCallback_;
  union {
    LogWithContextFn withContext;
    TAYGLogger noContext;
  } logger_;
  bool cloneNodeUsesContext_;
  bool loggerUsesContext_;

public:
  bool useWebDefaults = false;
  bool useLegacyStretchBehaviour = false;
  bool shouldDiffLayoutWithoutLegacyStretchBehaviour = false;
  bool printTree = false;
  float pointScaleFactor = 1.0f;
  std::array<bool, thinkingdatalayout::ta_yoga::enums::count<TAYGExperimentalFeature>()>
      experimentalFeatures = {};
  void* context = nullptr;

  TAYGConfig(TAYGLogger logger);
  void log(TAYGConfig*, TAYGNode*, TAYGLogLevel, void*, const char*, va_list);
  void setLogger(TAYGLogger logger) {
    logger_.noContext = logger;
    loggerUsesContext_ = false;
  }
  void setLogger(LogWithContextFn logger) {
    logger_.withContext = logger;
    loggerUsesContext_ = true;
  }
  void setLogger(std::nullptr_t) { setLogger(TAYGLogger{nullptr}); }

  TAYGNodeRef cloneNode(
      TAYGNodeRef node,
      TAYGNodeRef owner,
      int childIndex,
      void* cloneContext);
  void setCloneNodeCallback(TAYGCloneNodeFunc cloneNode) {
    cloneNodeCallback_.noContext = cloneNode;
    cloneNodeUsesContext_ = false;
  }
  void setCloneNodeCallback(CloneWithContextFn cloneNode) {
    cloneNodeCallback_.withContext = cloneNode;
    cloneNodeUsesContext_ = true;
  }
  void setCloneNodeCallback(std::nullptr_t) {
    setCloneNodeCallback(TAYGCloneNodeFunc{nullptr});
  }
};
