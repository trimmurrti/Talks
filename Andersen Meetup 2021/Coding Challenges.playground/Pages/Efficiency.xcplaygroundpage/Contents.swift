import Foundation

func measure(f: () -> ()) {
    let start = Date()

    f()
    
    let time = Date().timeIntervalSince(start)
    print("duration = \(floor(time / 60))m \(time.truncatingRemainder(dividingBy: 60))s ")
}

struct Dataset {
    let id: Int
    let name: String
}

class Image {
    let id: Int
    let datasetId: Int
    var dataset: Dataset?
    
    init(id: Int, datasetId: Int) {
        self.id = id
        self.datasetId = datasetId
    }
}

let datasetCount = 100

let datasets = (0..<datasetCount).map {
    Dataset(id: $0, name: "dataset \($0)")
}

let images = (0..<datasetCount * 1000).map {
    Image(id: $0, datasetId: $0 % datasetCount)
}

func match(images: [Image], datasets: [Dataset]) {
    for image in images {
        for dataset in datasets {
            if image.datasetId == dataset.id {
                image.dataset = dataset
            }
        }
    }
}

func solution(images: [Image], datasets: [Dataset]) {
    var lookupTable = [Int : Dataset](minimumCapacity: datasets.count)
    for dataset in datasets {
        lookupTable[dataset.id] = dataset
    }
    
    for image in images {
        image.dataset = lookupTable[image.datasetId]
    }
}

measure { match(images: images, datasets: datasets) }
measure { solution(images: images, datasets: datasets) }
