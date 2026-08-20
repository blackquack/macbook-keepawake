import AppKit

private final class KeepAwakeSwitch: NSView {
    var isOn = false {
        didSet { needsDisplay = true }
    }

    var controlEnabled = true {
        didSet { needsDisplay = true }
    }

    var onToggle: (() -> Void)?

    override var intrinsicContentSize: NSSize {
        NSSize(width: 36, height: 20)
    }

    override func draw(_ dirtyRect: NSRect) {
        let track = bounds.insetBy(dx: 1, dy: 2)
        let trackColor: NSColor

        if !controlEnabled {
            trackColor = .systemGray.withAlphaComponent(0.35)
        } else if isOn {
            trackColor = .systemBlue
        } else {
            trackColor = .systemGray
        }

        trackColor.setFill()
        NSBezierPath(
            roundedRect: track,
            xRadius: track.height / 2,
            yRadius: track.height / 2
        ).fill()

        let knobDiameter = track.height - 4
        let knobX = isOn
            ? track.maxX - knobDiameter - 2
            : track.minX + 2
        let knob = NSRect(
            x: knobX,
            y: track.minY + 2,
            width: knobDiameter,
            height: knobDiameter
        )

        NSColor.white.withAlphaComponent(controlEnabled ? 1.0 : 0.7).setFill()
        NSBezierPath(ovalIn: knob).fill()
    }

    override func mouseUp(with event: NSEvent) {
        guard controlEnabled else { return }
        onToggle?()
    }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        true
    }
}

final class ToggleMenuItemView: NSView {
    private let titleLabel = NSTextField(labelWithString: "Keep Awake")
    private let toggle = KeepAwakeSwitch()
    private let rowStack = NSStackView()

    var onToggle: (() -> Void)?

    override var intrinsicContentSize: NSSize {
        let width = titleLabel.intrinsicContentSize.width
            + rowStack.spacing
            + toggle.intrinsicContentSize.width
            + 24
        return NSSize(width: ceil(width), height: 36)
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    func update(isOn: Bool, isEnabled: Bool) {
        toggle.isOn = isOn
        toggle.controlEnabled = isEnabled
        titleLabel.textColor = isEnabled ? .labelColor : .disabledControlTextColor
    }

    private func configure() {
        titleLabel.font = NSFont.menuFont(ofSize: 13)

        toggle.onToggle = { [weak self] in
            self?.toggleChanged()
        }
        toggle.setAccessibilityLabel("Keep Awake")

        rowStack.orientation = .horizontal
        rowStack.alignment = .centerY
        rowStack.spacing = 12
        rowStack.edgeInsets = NSEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        rowStack.addArrangedSubview(titleLabel)
        rowStack.addArrangedSubview(toggle)

        addSubview(rowStack)
        rowStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rowStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            rowStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            rowStack.topAnchor.constraint(equalTo: topAnchor),
            rowStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        frame = NSRect(
            x: 0,
            y: 0,
            width: intrinsicContentSize.width,
            height: intrinsicContentSize.height
        )
    }

    @objc private func toggleChanged() {
        onToggle?()
    }
}

final class PowerStatusMenuItemView: NSView {
    private let label = NSTextField(labelWithString: "Power: Unknown")
    private var contentWidth: CGFloat = 0

    override var intrinsicContentSize: NSSize {
        NSSize(width: contentWidth, height: 32)
    }

    init() {
        let font = NSFont.menuFont(ofSize: 13)
        super.init(frame: .zero)
        configure(font: font)
        update(title: "Power: Unknown", isWarning: false)
    }

    required init?(coder: NSCoder) {
        let font = NSFont.menuFont(ofSize: 13)
        super.init(coder: coder)
        configure(font: font)
        update(title: "Power: Unknown", isWarning: false)
    }

    func update(title: String, isWarning: Bool) {
        label.stringValue = title
        label.textColor = isWarning ? .systemOrange : .secondaryLabelColor
        contentWidth = ceil(
            (title as NSString).size(withAttributes: [.font: label.font as Any]).width
        ) + 24
        frame.size = NSSize(width: contentWidth, height: 32)
        invalidateIntrinsicContentSize()
    }

    private func configure(font: NSFont) {
        label.font = font
        label.lineBreakMode = .byClipping
        label.usesSingleLineMode = true
        label.maximumNumberOfLines = 1
        label.setContentCompressionResistancePriority(.required, for: .horizontal)

        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
