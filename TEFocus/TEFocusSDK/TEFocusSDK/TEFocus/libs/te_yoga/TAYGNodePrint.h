
#ifdef DEBUG
#pragma once
#include <string>

#include "TAYoga.h"

namespace thinkingdatalayout {
namespace ta_yoga {

void TAYGNodeToString(
    std::string& str,
    TAYGNodeRef node,
    TAYGPrintOptions options,
    uint32_t level);

} // namespace ta_yoga
} // namespace thinkingdatalayout
#endif
