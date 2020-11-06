import Parser

struct SemVer {
    var major: Int
    var minor: Int
    var patch: Int
}

let semVer = zip(
    Parser.int,
    .literal("."),
    .int,
    .literal("."),
    .int
)
.map { ($0.0, $0.2, $0.4) }
.map(SemVer.init)

dump(semVer.run("1.2.3").result)
