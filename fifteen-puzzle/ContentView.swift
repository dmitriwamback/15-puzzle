//
//  ContentView.swift
//  fifteen-puzzle
//
//  Created by Dmitri on 2026-09-19.
//

import SwiftUI

struct ContentView: View {
    @State private var board = Array(1...15) + [0]
    @State private var moves = 0
    @State private var gameNumber = 0
    @State private var won = false
    @AppStorage("bestScore") private var bestScore = 0
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack {
                    Text("GAME")
                    Text("\(gameNumber)")
                }
                Spacer()
                
                VStack {
                    Text("MOVES")
                    Text("\(moves)")
                }
                Spacer()
                
                VStack {
                    Text("BEST")
                    Text("\(bestScore)")
                }
                Spacer()
                
                Button("New Game") {
                    newGame()
                }
            }.padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                ForEach(0..<16, id: \.self) { index in
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(board[index] == 0 ? Color.clear : board[index] % 2 == 0 ? Color.blue : Color.red)
                        
                        if board[index] != 0 {
                            Text("\(board[index])")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .onTapGesture {
                        move(index)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            newGame()
        }
    }
    
    private func move(_ index: Int) {
        guard let empty = board.firstIndex(of: 0) else { return }
        
        let row = index / 4
        let column = index % 4
        
        let emptyRow = empty / 4
        let emptyColumn = empty % 4
        
        let distance = abs(row - emptyRow) + abs(column - emptyColumn)
        guard distance == 1 else { return }
        
        withAnimation(.easeOut(duration: 0.15)) {
            board.swapAt(index, empty)
        }
        
        moves += 1
        didWin()
    }
    
    private func newGame() {
        
        gameNumber += 1
        moves = 0
        won = false
        
        repeat {
            board = Array(1...15) + [0]
            board.shuffle()
        } while !isSolvable(board)
    }
    
    private func isSolvable(_ board: [Int]) -> Bool {
        let tiles = board.filter { $0 != 0 }
        
        var inversions = 0
        
        for i in 0..<tiles.count {
            for j in (i + 1)..<tiles.count {
                if tiles[i] > tiles[j] {
                    inversions += 1
                }
            }
        }
        
        let emptyIndex = board.firstIndex(of: 0)!
        let emptyRowFromBottom = 4 - (emptyIndex / 4)
        
        return (inversions + emptyRowFromBottom) % 2 == 1
    }
    
    private func didWin() {
        if board == Array(1...15) + [0] {
            won = true
            if bestScore == 0 || moves < bestScore {
                bestScore = moves
            }
        }
    }
}

#Preview {
    ContentView()
}
