/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2014 - 2020 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See http://swift.org/LICENSE.txt for license information
 See http://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

#if canImport(Glibc)
@_exported import Glibc
#elseif os(Windows)
@_exported import CRT
@_exported import WinSDK
#elseif canImport(WASILibc)
@_exported import WASILibc

public let E2BIG: Int32 = 1
public let EACCES: Int32 = 2
public let EADDRINUSE: Int32 = 3
public let EADDRNOTAVAIL: Int32 = 4
public let EAFNOSUPPORT: Int32 = 5
public let EAGAIN: Int32 = 6
public let EALREADY: Int32 = 7
public let EBADF: Int32 = 8
public let EBADMSG: Int32 = 9
public let EBUSY: Int32 = 10
public let ECANCELED: Int32 = 11
public let ECHILD: Int32 = 12
public let ECONNABORTED: Int32 = 13
public let ECONNREFUSED: Int32 = 14
public let ECONNRESET: Int32 = 15
public let EDEADLK: Int32 = 16
public let EDESTADDRREQ: Int32 = 17
public let EDOM: Int32 = 18
public let EDQUOT: Int32 = 19
public let EEXIST: Int32 = 20
public let EFAULT: Int32 = 21
public let EFBIG: Int32 = 22
public let EHOSTUNREACH: Int32 = 23
public let EIDRM: Int32 = 24
public let EILSEQ: Int32 = 25
public let EINPROGRESS: Int32 = 26
public let EINVAL: Int32 = 28
public let EIO: Int32 = 29
public let EISCONN: Int32 = 30
public let EISDIR: Int32 = 31
public let ELOOP: Int32 = 32
public let EMFILE: Int32 = 33
public let EMLINK: Int32 = 34
public let EMSGSIZE: Int32 = 35
public let EMULTIHOP: Int32 = 36
public let ENAMETOOLONG: Int32 = 37
public let ENETDOWN: Int32 = 38
public let ENETRESET: Int32 = 39
public let ENETUNREACH: Int32 = 41
public let ENFILE: Int32 = 41
public let ENOBUFS: Int32 = 42
public let ENODEV: Int32 = 43
public let ENOENT: Int32 = 44
public let ENOEXEC: Int32 = 45
public let ENOLCK: Int32 = 46
public let ENOLINK: Int32 = 47
public let ENOMEM: Int32 = 48
public let ENOMSG: Int32 = 49
public let ENOPROTOOPT: Int32 = 50
public let ENOSPC: Int32 = 51
public let ENOSYS: Int32 = 52
public let ENOTCONN: Int32 = 53
public let ENOTDIR: Int32 = 54
public let ENOTEMPTY: Int32 = 55
public let ENOTRECOVERABLE: Int32 = 56
public let ENOTSOCK: Int32 = 57
public let ENOTSUP: Int32 = 58
public let ENOTTY: Int32 = 59
public let ENXIO: Int32 = 60
public let EOVERFLOW: Int32 = 61
public let EOWNERDEAD: Int32 = 62
public let EPERM: Int32 = 63
public let EPIPE: Int32 = 64
public let EPROTO: Int32 = 65
public let EPROTONOSUPPORT: Int32 = 66
public let EPROTOTYPE: Int32 = 67
public let ERANGE: Int32 = 68
public let EROFS: Int32 = 69
public let ESPIPE: Int32 = 70
public let ESRCH: Int32 = 71
public let ESTALE: Int32 = 72
public let ETIMEDOUT: Int32 = 73
public let ETXTBSY: Int32 = 74
public let EXDEV: Int32 = 75
public let ENOTCAPABLE: Int32 = 76
public let EOPNOTSUPP: Int32 = ENOTSUP
public let EWOULDBLOCK: Int32 = EAGAIN
public let ENODATA: Int32 = 9919
public let ENOSR: Int32 = 9922
public let ENOSTR: Int32 = 9924
public let ETIME: Int32 = 9935
public let O_APPEND: Int32 = 1 << 0
public let O_DSYNC: Int32 = 1 << 1
public let O_NONBLOCK: Int32 = 1 << 2
public let O_RSYNC: Int32 = 1 << 3
public let O_SYNC: Int32 = 1 << 4
public let O_CREAT: Int32 = (1 << 0) << 12
public let O_DIRECTORY: Int32 = (1 << 1) << 12
public let O_EXCL: Int32 = (1 << 2) << 12
public let O_TRUNC: Int32 = (1 << 3) << 12
public let O_NOFOLLOW: Int32 = 0x01000000
public let O_EXEC: Int32 = 0x02000000
public let O_RDONLY: Int32 = 0x04000000
public let O_SEARCH: Int32 = 0x08000000
public let O_ACCMODE: Int32 = O_EXEC | O_RDWR | O_SEARCH
public let SEEK_SET : Int32 = 0
public let SEEK_CUR : Int32 = 1
public let SEEK_END: Int32 = 2
#else
@_exported import Darwin.C
#endif

#if os(Windows)
private func __randname(_ buffer: UnsafeMutablePointer<CChar>) {
  let alpha = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  _ = (0 ..< 6).map { index in
      buffer[index] = CChar(alpha.shuffled().randomElement()!.utf8.first!)
  }
}

// char *mkdtemp(char *template);
// NOTE(compnerd) this is unsafe!  This assumes that the template is *ASCII*.
public func mkdtemp(
    _ template: UnsafeMutablePointer<CChar>?
) -> UnsafeMutablePointer<CChar>? {
  // Although the signature of the function is `char *(*)(char *)`, the C
  // library treats it as `char *(*)(char * _Nonull)`.  Most implementations
  // will simply use and trigger a segmentation fault on x86 (and similar faults
  // on other architectures) when the memory is accessed.  This roughly emulates
  // that by terminating in the case even though it is possible for us to return
  // an error.
  guard let template = template else { fatalError() }

  let length: Int = strlen(template)

  // Validate the precondition: the template must terminate with 6 `X` which
  // will be filled in to generate a unique directory.
  guard length >= 6, memcmp(template + length - 6, "XXXXXX", 6) == 0 else {
    _set_errno(EINVAL)
    return nil
  }

  // Attempt to create the directory
  var retries: Int = 100
  repeat {
    __randname(template + length - 6)
    if _mkdir(template) == 0 {
      return template
    }
    retries = retries - 1
  } while retries > 0

  return nil
}

// int mkstemps(char *template, int suffixlen);
public func mkstemps(
    _ template: UnsafeMutablePointer<CChar>?,
    _ suffixlen: Int32
) -> Int32 {
  // Although the signature of the function is `char *(*)(char *)`, the C
  // library treats it as `char *(*)(char * _Nonull)`.  Most implementations
  // will simply use and trigger a segmentation fault on x86 (and similar faults
  // on other architectures) when the memory is accessed.  This roughly emulates
  // that by terminating in the case even though it is possible for us to return
  // an error.
  guard let template = template else { fatalError() }

  let length: Int = strlen(template)

  // Validate the precondition: the template must terminate with 6 `X` which
  // will be filled in to generate a unique directory.
  guard length >= 6, memcmp(template + length - Int(suffixlen) - 6, "XXXXXX", 6) == 0 else {
    _set_errno(EINVAL)
    return -1
  }

  // Attempt to create file
  var retries: Int = 100
  repeat {
    __randname(template + length - Int(suffixlen) - 6)
    var fd: CInt = -1
    if _sopen_s(&fd, template, _O_RDWR | _O_CREAT | _O_BINARY | _O_NOINHERIT,
                _SH_DENYNO, _S_IREAD | _S_IWRITE) == 0 {
      return fd
    }
    retries = retries - 1
  } while retries > 0

  return -1
}
#endif
