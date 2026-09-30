#ifndef PXR_BASE_TF_SHARED_PTR_RETAIN_RELEASE_HELPER_H
#define PXR_BASE_TF_SHARED_PTR_RETAIN_RELEASE_HELPER_H

#include "pxr/pxrns.h"

#include <OneTBB/tbb/concurrent_hash_map.h>

#include <memory>
#include <utility>

PXR_NAMESPACE_OPEN_SCOPE

/// Bridges the non-intrusive reference counting of \c std::shared_ptr to
/// Swift's ARC for types that are not \c TfRefBase subclasses (and so can't
/// use \c Tf_RetainReleaseHelper).
///
/// \c Register records the \c shared_ptr under its raw pointer with an
/// initial count of 1 - the reference transferred to Swift. \c Retain and
/// \c Release adjust that count, and \c Release drops the stored
/// \c shared_ptr (permitting destruction of the underlying object, if this
/// was the last owner) once the count reaches 0.
template<class T> class Tf_SharedPtrRetainReleaseHelper {
 public:
  static T *Register(const std::shared_ptr<T> &ptr)
  {
    T *raw = ptr.get();
    typename _Table::accessor entry;
    _GetTable().insert(entry, raw);
    entry->second.first = ptr;
    entry->second.second += 1;
    return raw;
  }

  static void Retain(T *raw)
  {
    typename _Table::accessor entry;
    if (_GetTable().find(entry, raw)) {
      entry->second.second += 1;
    }
  }

  static void Release(T *raw)
  {
    // destroyed once the entry's lock is dropped, in case T's
    // destructor retains or releases something itself.
    std::shared_ptr<T> last;
    {
      typename _Table::accessor entry;
      if (!_GetTable().find(entry, raw) || --entry->second.second != 0) {
        return;
      }
      last = std::move(entry->second.first);
      _GetTable().erase(entry);
    }
  }

 private:
  using _Entry = std::pair<std::shared_ptr<T>, int>;
  using _Table = tbb::concurrent_hash_map<T *, _Entry>;

  static _Table &_GetTable()
  {
    static _Table table;
    return table;
  }
};

PXR_NAMESPACE_CLOSE_SCOPE

#endif  // PXR_BASE_TF_SHARED_PTR_RETAIN_RELEASE_HELPER_H
