//
//  TimerLinkTests.swift
//  ThunderCloudTests
//
//  Created by Jon Valijonov on 13/11/2026.
//  Copyright © 2026 threesidedcube. All rights reserved.
//

import XCTest
@testable import ThunderCloud

/// Tests for stopping the countdowns started from `TimerLink`s, e.g. the "Start Timer" button on a first aid page.
class TimerLinkTests: XCTestCase {

    /// The id of the timer link on the page under test
    private let timerLinkId = 12494

    /// The id of a timer link which lives on a different page
    private let otherPageTimerLinkId = 13655

    private let suiteName = "TimerLinkTests"

    private var userDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removePersistentDomain(forName: suiteName)
        userDefaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        UserDefaults.standard.removePersistentDomain(forName: suiteName)
        userDefaults = nil
        super.tearDown()
    }

    //MARK: - Helpers -

    private func timerLink(id: Int) -> StormLink {
        return StormLink(dictionary: [
            "class": "TimerLink",
            "id": id,
            "duration": 1200000,
            "title": [ "class": "Text", "content": "oqs" ]
        ])!
    }

    /// A page with a "Start Timer" button and a "Call 999" button embedded in its rows,
    /// followed by a row which links off to another page.
    private func makePage() -> ListPage {

        let page = ListPage(dictionary: [
            "class": "ListPage",
            "id": 5985,
            "children": [
                [
                    "class": "GroupView",
                    "children": [
                        [
                            "class": "AnnotatedListItemView",
                            "annotation": "1",
                            "embeddedLinks": [
                                [
                                    "class": "TimerLink",
                                    "id": timerLinkId,
                                    "duration": 1200000,
                                    "title": [ "class": "Text", "content": "oqs" ]
                                ]
                            ]
                        ],
                        [
                            "class": "AnnotatedListItemView",
                            "annotation": "2",
                            "embeddedLinks": [
                                [
                                    "class": "EmergencyLink",
                                    "title": [ "class": "Text", "content": "taj" ]
                                ]
                            ]
                        ]
                    ]
                ],
                [
                    "class": "GroupView",
                    "children": [
                        [
                            "class": "StandardListItemView",
                            "link": [
                                "class": "InternalLink",
                                "destination": "cache://pages/2281.json"
                            ]
                        ]
                    ]
                ]
            ]
        ])

        // The page's rows are created when its view loads
        page.loadViewIfNeeded()

        return page
    }

    /// Marks a countdown as running, in the same way that tapping its "Start Timer" button does.
    private func startCountdown(for link: StormLink) {
        userDefaults.set("2026-11-13T09:26:36+0000", forKey: link.timerKey)
    }

    private func isCountdownRunning(for link: StormLink) -> Bool {
        return userDefaults.object(forKey: link.timerKey) != nil
    }

    //MARK: - Timer key -

    /// A countdown is tracked by its link's id rather than by the link object, which is what allows
    /// a page that is opened again to find the countdown that was started the last time it was open.
    func test_timerKey_linksWithSameId_shareAKey() {
        XCTAssertEqual(timerLink(id: timerLinkId).timerKey, timerLink(id: timerLinkId).timerKey)
        XCTAssertNotEqual(timerLink(id: timerLinkId).timerKey, timerLink(id: otherPageTimerLinkId).timerKey)
    }

    //MARK: - Stopping a page's timers -

    /// Enforces that stopping a page's timers ends a running countdown and cancels its "countdown complete" notification.
    func test_stopTimers_runningCountdown_stopsItAndCancelsItsNotification() {
        let link = timerLink(id: timerLinkId)
        startCountdown(for: link)

        var cancelledNotifications: [String] = []
        let stoppedTimers = makePage().stopTimers(in: userDefaults) { cancelledNotifications.append(contentsOf: $0) }

        XCTAssertTrue(stoppedTimers)
        XCTAssertFalse(isCountdownRunning(for: link))
        XCTAssertEqual(cancelledNotifications, [link.timerKey])
    }

    /// Enforces that once a page's timers have been stopped, opening the page again doesn't pick the countdown
    /// back up: the newly created page has nothing left to stop.
    func test_stopTimers_pageOpenedAgain_hasNoRunningCountdown() {
        startCountdown(for: timerLink(id: timerLinkId))

        _ = makePage().stopTimers(in: userDefaults) { _ in }

        var cancelledNotifications: [String] = []
        let stoppedTimers = makePage().stopTimers(in: userDefaults) { cancelledNotifications.append(contentsOf: $0) }

        XCTAssertFalse(stoppedTimers)
        XCTAssertTrue(cancelledNotifications.isEmpty)
    }

    /// Enforces that stopping a page's timers does nothing when none of them are running.
    func test_stopTimers_noRunningCountdown_doesNothing() {
        var cancelledNotifications: [String] = []
        let stoppedTimers = makePage().stopTimers(in: userDefaults) { cancelledNotifications.append(contentsOf: $0) }

        XCTAssertFalse(stoppedTimers)
        XCTAssertTrue(cancelledNotifications.isEmpty)
    }

    /// Enforces that stopping a page's timers leaves a countdown which was started on a different page running.
    func test_stopTimers_countdownOnAnotherPage_isLeftRunning() {
        let otherPageLink = timerLink(id: otherPageTimerLinkId)
        startCountdown(for: otherPageLink)

        var cancelledNotifications: [String] = []
        let stoppedTimers = makePage().stopTimers(in: userDefaults) { cancelledNotifications.append(contentsOf: $0) }

        XCTAssertFalse(stoppedTimers)
        XCTAssertTrue(isCountdownRunning(for: otherPageLink))
        XCTAssertTrue(cancelledNotifications.isEmpty)
    }

    //MARK: - Redrawing a cell -

    /// Enforces that a cell whose timers have stopped puts its timer button back to "Start Timer",
    /// and leaves the other buttons in the cell alone.
    func test_timersDidStop_resetsTimerButtonsOnly() {

        let cell = StormTableViewCell(style: .default, reuseIdentifier: nil)
        let stackView = UIStackView()
        cell.contentView.addSubview(stackView)
        cell.embeddedLinksStackView = stackView

        let timerButton = InlineButtonView()
        timerButton.link = timerLink(id: timerLinkId)
        timerButton.setTitle("19:42", for: .normal)
        stackView.addArrangedSubview(timerButton)

        let emergencyButton = InlineButtonView()
        emergencyButton.link = StormLink(dictionary: [ "class": "EmergencyLink" ])
        emergencyButton.setTitle("Call 999", for: .normal)
        stackView.addArrangedSubview(emergencyButton)

        cell.timersDidStop()

        XCTAssertEqual(timerButton.title(for: .normal), "Start Timer".localised(with: "_STORM_TIMER_START_TITLE"))
        XCTAssertEqual(emergencyButton.title(for: .normal), "Call 999")
    }
}
