//
//  MemberViewModel.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 27.12.2023.
//

import RxSwift
import RxCocoa

final class MemberViewModel {
    private let trackInfo: Driver<MemberTrackInfo>
    
    private lazy var trackManager = TrackManager()
    
    init(memberTrackInfo: MemberTrackInfo) {
        self.trackInfo = BehaviorRelay(value: memberTrackInfo).asDriver()
    }
}

// MARK: Public
extension MemberViewModel {
    struct Input {}
    
    struct Output {
        let elements: Driver<[MemberTableElement]>
    }
    
    func configure(input: Input) -> Output {
        Output(
            elements: makeElements()
        )
    }
}

// MARK: Private
private extension MemberViewModel {
    func makeElements() -> Driver<[MemberTableElement]> {
        trackInfo
            .map { trackInfo -> [MemberTableElement] in
                var result = [MemberTableElement]()
                
                let info = MemberInfoElement(trackInfo: trackInfo)
                result.append(.info(info))
                
                result.append(.title("Member.CurrentPosition".localized))
                
                result.append(.buttons)
                
                result.append(.title("Member.History".localized))
                
                return result
            }
    }
}
