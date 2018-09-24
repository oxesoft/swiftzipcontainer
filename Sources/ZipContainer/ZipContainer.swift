import Foundation

public class ZipContainer {
    private let VERSION : UInt16 = 10
    private let UTF8_FLAG : UInt16 = 1 << 11
    private let NO_COMPRESSION : UInt16 = 0

    private var result = Data()
    private var cDir = Data()
    private var offset : UInt32 = 0
    private var curOffset : UInt32 = 0
    private var entries : UInt16 = 0

    public init() {
    }

    private func writeLong(_ out :inout Data, _ long: UInt32) {
        out.append(UInt8(long & 0xFF))
        out.append(UInt8((long >> 8) & 0xFF))
        out.append(UInt8((long >> 16) & 0xFF))
        out.append(UInt8((long >> 24) & 0xFF))
    }

    private func writeShort(_ out : inout Data, _ short: UInt16) {
        out.append(UInt8(short & 0xFF))
        out.append(UInt8((short >> 8) & 0xFF))
    }

    public func putNextEntry(_ fileName: String, _ fileContent: Data, _ date: Date = Date()) {
        if entries >= 0xffff {
            print("entries limit reached in a single zip")
            return
        }
        let components = Calendar.current.dateComponents(in: TimeZone.current, from: date)
        let h = UInt16(components.hour    ?? 0)
        let m = UInt16(components.minute  ?? 0)
        let s = UInt16(components.second  ?? 0)
        let time = (h << 11) | (m << 5) | (s >> 1)
        let y = UInt16(components.year   ?? 0)
        let M = UInt16(components.month  ?? 0)
        let d = UInt16(components.day    ?? 0)
        let date = ((y - 1980) << 9) | (M << 5) | d
        let crc = CRC32.calculate(fileContent)
        let nameBytes = fileName.data(using: .utf8) ?? Data()
        //-----------------------------------------
        writeLong(&result, 0x04034b50)
        writeShort(&result, VERSION)
        writeShort(&result, UTF8_FLAG)
        writeShort(&result, NO_COMPRESSION)
        writeShort(&result, time)
        writeShort(&result, date)
        writeLong(&result, crc)
        writeLong(&result, UInt32(fileContent.count))
        writeLong(&result, UInt32(fileContent.count))
        writeShort(&result, UInt16(nameBytes.count))
        writeShort(&result, 0) // extra
        result.append(nameBytes)
        result.append(fileContent)
        // central directory
        writeLong(&cDir, 0x02014b50)
        writeShort(&cDir, VERSION)
        writeShort(&cDir, VERSION)
        writeShort(&cDir, UTF8_FLAG)
        writeShort(&cDir, NO_COMPRESSION)
        writeShort(&cDir, time)
        writeShort(&cDir, date)
        writeLong(&cDir, crc)
        writeLong(&cDir, UInt32(fileContent.count))
        writeLong(&cDir, UInt32(fileContent.count))
        writeShort(&cDir, UInt16(nameBytes.count))
        writeShort(&cDir, 0) // extra
        writeShort(&cDir, 0) // comment
        writeShort(&cDir, 0) // disk start
        writeShort(&cDir, 0) // internal file attibutes
        writeLong(&cDir, 0) // external file attibutes
        writeLong(&cDir, offset)
        cDir.append(nameBytes)
        offset += 30 + UInt32(fileContent.count) + UInt32(nameBytes.count)
        entries += 1
    }

    public func getResult() -> Data {
        let cDirSize = UInt32(cDir.count)
        writeLong(&cDir, 0x6054b50)
        writeShort(&cDir, 0) // disk number
        writeShort(&cDir, 0) // start disk
        writeShort(&cDir, entries)
        writeShort(&cDir, entries)
        writeLong(&cDir, cDirSize)
        writeLong(&cDir, offset)
        writeShort(&cDir, 0) // comment
        result.append(cDir)
        return result
    }
}
