import 'dart:convert';
import 'dart:typed_data';

enum FileEncoding {
  utf8,
  utf16le,
  utf16be,
  ascii,
  latin1,
}

class EncodingService {
  static const Map<FileEncoding, String> _encodingNames = {
    FileEncoding.utf8: 'UTF-8',
    FileEncoding.utf16le: 'UTF-16 LE',
    FileEncoding.utf16be: 'UTF-16 BE',
    FileEncoding.ascii: 'ASCII',
    FileEncoding.latin1: 'ANSI (Latin-1)',
  };

  static String getEncodingName(FileEncoding encoding) {
    return _encodingNames[encoding] ?? 'Unknown';
  }

  static List<FileEncoding> get supportedEncodings => FileEncoding.values;

  static Encoding getEncoding(FileEncoding encoding) {
    switch (encoding) {
      case FileEncoding.utf8:
        return utf8;
      case FileEncoding.utf16le:
      case FileEncoding.utf16be:
        // UTF-16 is handled separately in encode/decode methods
        throw UnsupportedError('UTF-16 requires special handling');
      case FileEncoding.ascii:
        return ascii;
      case FileEncoding.latin1:
        return latin1;
    }
  }

  static FileEncoding detectEncoding(List<int> bytes) {
    // Check for BOM (Byte Order Mark)
    if (bytes.length >= 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF) {
      return FileEncoding.utf8;
    }
    if (bytes.length >= 2) {
      if (bytes[0] == 0xFF && bytes[1] == 0xFE) {
        return FileEncoding.utf16le;
      }
      if (bytes[0] == 0xFE && bytes[1] == 0xFF) {
        return FileEncoding.utf16be;
      }
    }

    // Try to decode as UTF-8
    try {
      utf8.decode(bytes, allowMalformed: false);
      return FileEncoding.utf8;
    } catch (_) {
      // Not valid UTF-8
    }

    // Check if ASCII
    if (bytes.every((byte) => byte < 128)) {
      return FileEncoding.ascii;
    }

    // Default to Latin1 (ANSI) if all else fails
    return FileEncoding.latin1;
  }

  static String decodeBytes(List<int> bytes, FileEncoding encoding) {
    switch (encoding) {
      case FileEncoding.utf16le:
        final data = ByteData(bytes.length);
        for (var i = 0; i < bytes.length; i++) {
          data.setUint8(i, bytes[i]);
        }
        final buffer = StringBuffer();
        for (var i = 0; i < bytes.length - 1; i += 2) {
          buffer.writeCharCode(data.getUint16(i, Endian.little));
        }
        return buffer.toString();

      case FileEncoding.utf16be:
        final data = ByteData(bytes.length);
        for (var i = 0; i < bytes.length; i++) {
          data.setUint8(i, bytes[i]);
        }
        final buffer = StringBuffer();
        for (var i = 0; i < bytes.length - 1; i += 2) {
          buffer.writeCharCode(data.getUint16(i, Endian.big));
        }
        return buffer.toString();

      default:
        final codec = getEncoding(encoding);
        return codec.decode(bytes);
    }
  }

  static List<int> encodeString(String text, FileEncoding encoding) {
    switch (encoding) {
      case FileEncoding.utf16le:
        final List<int> bytes = [];
        for (final codeUnit in text.codeUnits) {
          bytes.add(codeUnit & 0xFF);
          bytes.add((codeUnit >> 8) & 0xFF);
        }
        return bytes;

      case FileEncoding.utf16be:
        final List<int> bytes = [];
        for (final codeUnit in text.codeUnits) {
          bytes.add((codeUnit >> 8) & 0xFF);
          bytes.add(codeUnit & 0xFF);
        }
        return bytes;

      default:
        final codec = getEncoding(encoding);
        return codec.encode(text);
    }
  }
}
