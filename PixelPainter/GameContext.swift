//
//  GameContext.swift
//  PixelPainter
//
//  Created by Tim Hsieh on 10/22/24.
//

import GameplayKit
import SwiftUI

class GameContext: ObservableObject {
    @Published private(set) var scene: GameScene!
    @Published private(set) var stateMachine: GKStateMachine?
    @Published var layoutInfo: LayoutInfo
    @Published var gameInfo: GameInfo

    init() {
        // First initialize basic info based on screen bounds
        self.layoutInfo = LayoutInfo(
            gridDimension: 3,
            screenSize: UIScreen.main.bounds.size
        )
        self.gameInfo = GameInfo()

        // Create scene with self as context
        self.scene = GameScene(context: self, size: UIScreen.main.bounds.size)

        configureStates()
    }

    func updateGridDimension(_ dimension: Int) {
        layoutInfo = LayoutInfo(
            gridDimension: dimension,
            screenSize: scene.size
        )
    }

    func configureStates() {
        stateMachine = GKStateMachine(states: [
            MemorizeState(gameScene: scene),
            PlayState(gameScene: scene),
            GameOverState(gameScene: scene),
        ])
    }

    func resetGame() {
        gameInfo = GameInfo()
        layoutInfo = LayoutInfo(
            gridDimension: 3,
            screenSize: scene.size
        )
        scene.queueManager.refreshImageQueue(forGridSize: 3)
        stateMachine?.enter(MemorizeState.self)
    }
}

struct LayoutInfo {
    var gridDimension: Int
    var gridSize: CGSize
    var bankHeight: CGFloat

    // Base reference values
    private let baseWidth: CGFloat = 393  // iPhone 14 Pro width
    private let baseHeight: CGFloat = 852  // iPhone 14 Pro height
    private let baseGridSize: CGFloat = 350
    private let baseBankHeight: CGFloat = 150

    // Fixed values for non-iPhone SE
    private let defaultGridSize = CGSize(width: 350, height: 350)
    private let defaultBankHeight: CGFloat = 150

    init(gridDimension: Int = 3, screenSize: CGSize) {
        self.gridDimension = gridDimension

        let isIPhoneSE = screenSize.height <= 667
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad

        if isIPhoneSE {
            // Scale grid and bank size for iPhone SE
            let widthScale = screenSize.width / baseWidth
            let heightScale = screenSize.height / baseHeight
            let scale = min(widthScale, heightScale)

            self.gridSize = CGSize(
                width: baseGridSize * scale,
                height: baseGridSize * scale
            )
            self.bankHeight = baseBankHeight * scale
        } else if isIPad {
            self.gridSize = defaultGridSize
            self.bankHeight = defaultBankHeight
        } else {
            self.gridSize = defaultGridSize
            self.bankHeight = defaultBankHeight
        }
    }

    var pieceSize: CGSize {
        return CGSize(
            width: gridSize.width / CGFloat(gridDimension),
            height: gridSize.height / CGFloat(gridDimension)
        )
    }

}

struct GameInfo {
    var currentImage: UIImage?
    var pieces: [PuzzlePiece] = []
    var score: Int = 0
    var timeRemaining: TimeInterval = 10
    var level: Int = 1
    var boardSize = 3  //3x3, 4 = 4x4, so on...

}

struct PuzzlePiece: Identifiable {
    let id = UUID()
    let image: UIImage
    var correctPosition: CGPoint
    var currentPosition: CGPoint
    var isPlaced: Bool = false
}
