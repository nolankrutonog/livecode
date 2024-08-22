////
////  TestView.swift
////  livecode
////
////  Created by Nolan Krutonog on 8/21/24.
////
//
import SwiftUI

struct DragAndDropView: View {
    @Binding var bottomBoxes: [String] //  = (1...18).map { "Box \($0)" }
    @Binding var topBoxes: [String] //  = []

    let columns = [GridItem(.adaptive(minimum: 60))]
    let maxTopBoxes = 7

    var body: some View {
        VStack(spacing: 20) {
            sectionView(title: "Top Section", boxes: $topBoxes, color: .blue, otherBoxes: $bottomBoxes, isTopSection: true)
            sectionView(title: "Bottom Section", boxes: $bottomBoxes, color: .green, otherBoxes: $topBoxes, isTopSection: false)
        }
        .padding()
        .background(Color.black.opacity(0.05))
        .edgesIgnoringSafeArea(.all)
    }

    func sectionView(title: String, boxes: Binding<[String]>, color: Color, otherBoxes: Binding<[String]>, isTopSection: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(boxes.wrappedValue, id: \.self) { box in
                            Text(box)
                                .frame(width: 60, height: 60)
                                .background(color.opacity(0.8))
                                .cornerRadius(8)
                                .shadow(color: color.opacity(0.3), radius: 2, x: 0, y: 1)
                                .onDrag {
                                    NSItemProvider(object: box as NSString)
                                }
                        }
                    }
                    .padding()
                }
            }
            .frame(height: 200)
            .onDrop(of: [.text], delegate: BoxdropDelegate(destinationBoxes: boxes, sourceBoxes: otherBoxes, isTopSection: isTopSection, maxTopBoxes: maxTopBoxes))
        }
    }
}

struct BoxdropDelegate: DropDelegate {
    @Binding var destinationBoxes: [String]
    @Binding var sourceBoxes: [String]
    let isTopSection: Bool
    let maxTopBoxes: Int

    func performDrop(info: DropInfo) -> Bool {
        guard let itemProvider = info.itemProviders(for: [.text]).first else { return false }
        
        itemProvider.loadObject(ofClass: NSString.self) { (reading, error) in
            if let error = error {
                print("Error loading dragged item: \(error.localizedDescription)")
                return
            }
            guard let item = reading as? String else { return }
            
            DispatchQueue.main.async {
                if let sourceIndex = self.sourceBoxes.firstIndex(of: item) {
                    self.sourceBoxes.remove(at: sourceIndex)
                    
                    if self.isTopSection {
                        if self.destinationBoxes.count < self.maxTopBoxes {
                            self.destinationBoxes.append(item)
                        } else {
                            // If top section is full, put the box back in the source
                            self.sourceBoxes.insert(item, at: sourceIndex)
                        }
                    } else {
                        self.destinationBoxes.insert(item, at: 0)
                    }
                }
            }
        }
        return true
    }
}

struct DragAndDropView_Previews: PreviewProvider {
    @State static var bottomBoxes: [String] = (1...18).map { "Box \($0)" }
    @State static var topBoxes: [String] = []
    static var previews: some View {
        DragAndDropView(bottomBoxes: $bottomBoxes, topBoxes: $topBoxes)
    }
}
