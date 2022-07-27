//
//  ContentView.swift
//  SwipeAction
//
//  Created by Marvin Messenzehl on 27.07.22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        SwipeItem(content: {
                    Text("To-do item")
                    .bold()
                 },
                 left: {
                    ZStack {
                        Rectangle()
                            .fill(Color.orange)
                        
                        Image(systemName: "calendar")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                    }
                 },
                 right: {
                    ZStack {
                        Rectangle()
                            .fill(Color.blue)
                        
                        Image(systemName: "smallcircle.filled.circle")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                    }
                 }, itemHeight: 50)
    }
}

struct SwipeItem<Content: View, Left:View, Right:View>: View {
    var content: () -> Content
    var left:() -> Left
    var right:() -> Right
    var itemHeight: CGFloat
    
    init(@ViewBuilder content: @escaping () -> Content,
         @ViewBuilder left: @escaping () -> Left,
         @ViewBuilder right: @escaping () -> Right,
         itemHeight: CGFloat) {
        self.content = content
        self.left = left
        self.right = right
        self.itemHeight = itemHeight
    }
    
    @State var hoffset: CGFloat = 0
    @State var anchor: CGFloat = 0
    
    // Computed Properties
    let screenWidth = UIScreen.main.bounds.width
    var anchorWidth: CGFloat { screenWidth / 3 }
    var swipeThreshold: CGFloat {screenWidth / 15 }
    
    // Swipe Thresshold
    @State var rightPast = false
    @State var leftPast = false
    
    var drag: some Gesture {
        DragGesture()
            .onChanged{ value in
                withAnimation {
                    hoffset = anchor + value.translation.width
                    
                    if anchor > 0 {
                        leftPast = hoffset > anchorWidth - swipeThreshold
                    } else {
                        leftPast = hoffset > swipeThreshold
                    }
                    
                    if anchor < 0 {
                        rightPast = hoffset < -anchorWidth + swipeThreshold
                    } else {
                        rightPast = hoffset < -swipeThreshold
                    }
                }
            }
            .onEnded{ value in
                withAnimation {
                    if rightPast {
                        anchor = -anchorWidth
                    } else if leftPast {
                        anchor = anchorWidth
                    } else {
                        anchor = 0
                    }
                    hoffset = anchor
                }
            }
    }
    
    var body: some View {
        GeometryReader {
            geo in
            HStack(spacing: 0) {
                left()
                    .frame(width: anchorWidth)
                    .zIndex(1)
                    .clipped()
                
                content()
                    .frame(width: geo.size.width)
                
                right()
                    .frame(width: anchorWidth)
                    .zIndex(1)
                    .clipped()
            }
            .offset(x: -anchorWidth + hoffset)
            .frame(maxHeight: itemHeight)
            .contentShape(Rectangle())
            .gesture(drag)
            .clipped()
        }
    }
        
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
