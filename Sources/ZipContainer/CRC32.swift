import Foundation

final class CRC32 {
    static let table = initTable()
    private static func initTable() -> [UInt32] {
        let p = [0,1,2,4,5,7,8,10,11,12,16,22,23,26]
        var polynomial : UInt32 = 0
        var indexP = 0
        for _ in 0 ..< p.count {
            polynomial |= 1 << (31 - p[indexP])
            indexP += 1
        }
        var table: [UInt32] = [UInt32](repeating: 0x00000000, count: 256)
        var i = 1
        for _ in 1 ..< table.count {
            var crc: UInt32 = UInt32(i)
            for _ in 0 ..< 8 {
                crc = crc & 1 > 0 ? (crc >> 1) ^ polynomial : crc >> 1
            }
            table[i] = crc
            i += 1
        }
        return table
    }

    static func calculate(_ data: Data) -> UInt32 {
        var crc: UInt32 = 0xffffffff
        for i in 0 ..< data.count {
            crc = table[Int((crc ^ UInt32(data[i])) & 0xff)] ^ (crc >> 8)
        }
        return crc ^ 0xffffffff
    }
}
