//
//  ColorPickerView.swift
//  TogglDesktop
//
//  Created by Nghia Tran on 3/28/19.
//  Copyright © 2019 Alari. All rights reserved.
//

import Cocoa

protocol ColorPickerViewDelegate: class {

    func colorPickerDidSelectColor(_ color: ProjectColor)
}

final class ColorPickerView: NSView {

    fileprivate struct Constants {
        static let ColorViewItemID = NSUserInterfaceItemIdentifier(rawValue: "ColorViewItem")
    }

    // MARK: OUTLET

    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var colorWheelView: ColorGraphicsView!
    @IBOutlet weak var colorWheelContainerView: NSView!
    
    // MARK: Variables

    weak var delegate: ColorPickerViewDelegate?
    fileprivate lazy var colors: [ProjectColor] = ProjectColor.defaultColors

    // MARK: View Cycle

    override func awakeFromNib() {
        super.awakeFromNib()

        initCommon()
        initCollectionView()
    }

    // MARK: Public

    func select(_ color: ProjectColor) {
        guard let index = colors.firstIndex(where: { $0 == color }) else { return }
        collectionView.selectItems(at: Set<IndexPath>.init(arrayLiteral: IndexPath.init(item: index, section: 0)), scrollPosition: [])
    }

    @IBAction func resetBtnOnTap(_ sender: Any) {
    }
}

// MARK: Private
extension ColorPickerView {

    fileprivate func initCommon() {
        colorWheelView.selectedHSBComponent = .brightness
        colorWheelView.delegate = self
        colorWheelContainerView.wantsLayer = true
        colorWheelContainerView.layer?.masksToBounds = true
        wantsLayer = true
        layer?.masksToBounds = true
        layer?.cornerRadius = 8
        if #available(OSX 10.13, *) {
            layer?.backgroundColor = NSColor(named: "color-picker-background")?.cgColor
        } else {
            layer?.backgroundColor = ConvertHexColor.hexCode(toNSColor: "#f9f9f9")?.cgColor
        }
    }

    fileprivate func initCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        let nib = NSNib(nibNamed: "ColorViewItem", bundle: nil)
        collectionView.register(nib, forItemWithIdentifier: Constants.ColorViewItemID)

        let flow = NSCollectionViewFlowLayout()
        flow.itemSize = CGSize(width: 24.0, height: 24.0)
        flow.sectionInset = NSEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        flow.minimumLineSpacing = 7.0
        flow.minimumInteritemSpacing = 7.0
        collectionView.collectionViewLayout = flow
    }
}

// MARK: NSCollectionViewDelegate & NSCollectionViewDataSource
extension ColorPickerView: NSCollectionViewDelegate, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let color = colors[indexPath.item]
        let view = collectionView.makeItem(withIdentifier: Constants.ColorViewItemID, for: indexPath) as! ColorViewItem
        view.render(color)
        return view
    }

    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let selection = indexPaths.first else { return }
        let color = colors[selection.item]
        delegate?.colorPickerDidSelectColor(color)
    }
}

// MARK: ColorPickerViewDelegate

extension ColorPickerView: ChangeColorDelegate {

    func colorChanged(color: HSV) {
        notifySelectedColorChange(with: color)
    }

    func colorSettled(color: HSV) {
        collectionView.deselectAll(collectionView)
        notifySelectedColorChange(with: color)
    }

    private func notifySelectedColorChange(with color: HSV) {
        let hex = color.toRGB().toHEX()
        let color = ProjectColor(colorHex: hex)
        delegate?.colorPickerDidSelectColor(color)
    }
}
