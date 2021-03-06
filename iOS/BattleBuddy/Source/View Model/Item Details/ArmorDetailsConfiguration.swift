//
//  ArmorDetailsConfiguration.swift
//  BattleBuddy
//
//  Created by Mike on 7/17/19.
//  Copyright © 2019 Veritas. All rights reserved.
//

import UIKit

class ArmorDetailsConfiguration: NSObject, ItemDetailsConfiguration, UITableViewDelegate, UITableViewDataSource {
    var armor: Armor
    var item: BaseItem
    var delegate: ItemDetailsSectionDelegate?

    let propertiesStackView = BaseStackView(xPaddingCompact: 0.0)
    let propertiesHeaderView = SectionHeaderView(headerText: Localized("properties"))
    lazy var propertiesTableView = { BaseTableView(dataSource: self, delegate: self) }()
    let armorTypeCell = BaseTableViewCell(text: Localized("armor_type"), accessory: .none, selection: .none)
    let armorClassCell = BaseTableViewCell(text: Localized("armor_class"))
    let armorPointsCell = BaseTableViewCell(text: Localized("armor_points"), accessory: .none, selection: .none)
    let armorMaterialCell = BaseTableViewCell(text: Localized("armor_material"))
    let armorZonesCell = BaseTableViewCell(text: Localized("armor_zones"), accessory: .none, selection: .none)
    lazy var propertiesCells = { [armorTypeCell, armorClassCell, armorPointsCell, armorMaterialCell, armorZonesCell] }()

    let penaltiesStackView = BaseStackView(xPaddingCompact: 0.0)
    let penaltiesHeaderView = SectionHeaderView(headerText: Localized("penalties"))
    lazy var penaltiesTableView = { BaseTableView(dataSource: self, delegate: self) }()
    let hearingPenaltyCell = BaseTableViewCell(text: Localized("hearing_penalty"), accessory: .none, selection: .none)
    let speedPenaltyCell = BaseTableViewCell(text: Localized("speed_penalty"), accessory: .none, selection: .none)
    let turnSpeedPenaltyCell = BaseTableViewCell(text: Localized("turn_speed_penalty"), accessory: .none, selection: .none)
    let ergoPenaltyCell = BaseTableViewCell(text: Localized("ergo_penalty"), accessory: .none, selection: .none)
    lazy var penaltiesCells: [BaseTableViewCell] = {
        switch armor.armorType {
        case .body:
            return [speedPenaltyCell, turnSpeedPenaltyCell, ergoPenaltyCell]
        case .helmet, .visor, .attachment:
            return [hearingPenaltyCell, speedPenaltyCell, turnSpeedPenaltyCell, ergoPenaltyCell]
        }
    }()

    let exploreStackView = BaseStackView(xPaddingCompact: 0.0)
    let exploreHeaderView = SectionHeaderView(headerText: Localized("explore"))
    lazy var exploreTableView = { BaseTableView(dataSource: self, delegate: self) }()
    let compareCell = BaseTableViewCell(text: Localized("compare"))
    let penChanceCalcCell = BaseTableViewCell(text: Localized("pen_chance"))
    let combatSimCell = BaseTableViewCell(text: "main_menu_combat_sim".local())
    let shootingRangeCell = BaseTableViewCell(text: "main_menu_shooting_range".local())
    lazy var exploreCells: [BaseTableViewCell] = { return [compareCell, shootingRangeCell, penChanceCalcCell, combatSimCell] }()

    init(_ armor: Armor) {
        self.armor = armor
        self.item = armor

        super.init()

        propertiesStackView.addArrangedSubview(propertiesHeaderView)
        propertiesStackView.addArrangedSubview(propertiesTableView)

        penaltiesStackView.addArrangedSubview(penaltiesHeaderView)
        penaltiesStackView.addArrangedSubview(penaltiesTableView)
        penaltiesStackView.addArrangedSubview(UIView())

        exploreStackView.addArrangedSubview(exploreHeaderView)
        exploreStackView.addArrangedSubview(exploreTableView)

        armorTypeCell.detailTextLabel?.text = armor.armorType.local()
        armorClassCell.detailTextLabel?.text = armor.armorClass.local()
        armorPointsCell.detailTextLabel?.text = String(armor.maxDurability)
        armorZonesCell.detailTextLabel?.text = armor.localizedArmorZonesDisplayString()
        armorMaterialCell.detailTextLabel?.text = armor.material.local()

        speedPenaltyCell.detailTextLabel?.text = String(armor.penalties.movementSpeed)
        turnSpeedPenaltyCell.detailTextLabel?.text = String(armor.penalties.turnSpeed)
        ergoPenaltyCell.detailTextLabel?.text = String(armor.penalties.ergonomics)
        hearingPenaltyCell.detailTextLabel?.text = armor.penalties.hearing.local()

        setupConstraints()
    }

    func setupConstraints() {
        let propertyTableViewHeight = CGFloat(propertiesCells.count) * propertiesTableView.rowHeight
        let totalPropertyCardHeight: CGFloat = propertiesHeaderView.height() + propertyTableViewHeight + propertiesStackView.totalPadding
        propertiesStackView.constrainHeight(totalPropertyCardHeight)

        let penaltiesTableViewHeight = CGFloat(penaltiesCells.count) * penaltiesTableView.rowHeight
        let totalPenaltiesCardHeight: CGFloat = penaltiesHeaderView.height() + penaltiesTableViewHeight + penaltiesStackView.totalPadding
        penaltiesStackView.constrainHeight(totalPenaltiesCardHeight)

        let exlporeTableViewHeight = CGFloat(exploreCells.count) * exploreTableView.rowHeight
        let totalExploreCardHeight: CGFloat = exploreHeaderView.height() + exlporeTableViewHeight + exploreStackView.totalPadding
        exploreStackView.constrainHeight(totalExploreCardHeight)
    }

    func getArrangedSubviews() -> [UIView] {
        return [propertiesStackView, penaltiesStackView, exploreStackView]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case propertiesTableView: return propertiesCells.count
        case penaltiesTableView: return penaltiesCells.count
        case exploreTableView: return exploreCells.count
        default: fatalError()
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case propertiesTableView: return propertiesCells[indexPath.row]
        case penaltiesTableView: return penaltiesCells[indexPath.row]
        case exploreTableView: return exploreCells[indexPath.row]
        default: fatalError()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let cell = tableView.cellForRow(at: indexPath)

        let dbManager = DependencyManagerImpl.shared.databaseManager()

        switch cell {
        case armorClassCell:
            self.delegate?.showLoading(show: true)

            switch armor.armorType {
            case .body:
                dbManager.getAllBodyArmorOfClass(armorClass: armor.armorClass) { allArmor in
                    self.delegate?.showLoading(show: false)

                    let armorClassVC = BaseItemPreviewViewController(delegate: nil, config: ArmorPreviewConfiguration(items: allArmor))
                    armorClassVC.title = self.armor.armorClass.local()
                    self.delegate?.showViewController(viewController: armorClassVC)
                }
            case .helmet, .visor, .attachment:
                dbManager.getAllHelmetsOfClass(armorClass: armor.armorClass) { allArmor in
                    self.delegate?.showLoading(show: false)

                    let armorClassVC = BaseItemPreviewViewController(delegate: nil, config: ArmorPreviewConfiguration(items: allArmor))
                    armorClassVC.title = self.armor.armorClass.local()
                    self.delegate?.showViewController(viewController: armorClassVC)
                }
            }
        case armorMaterialCell:
            self.delegate?.showLoading(show: true)

            switch armor.armorType {
            case .body:
                dbManager.getAllBodyArmorWithMaterial(material: armor.material) { allArmor in
                    self.delegate?.showLoading(show: false)

                    let armorVC = BaseItemPreviewViewController(delegate: nil, config: ArmorPreviewConfiguration(items: allArmor))
                    armorVC.title = self.armor.material.local()
                    self.delegate?.showViewController(viewController: armorVC)
                }
            case .helmet, .visor, .attachment:
                dbManager.getAllHelmetsWithMaterial(material: armor.material) { allArmor in
                    self.delegate?.showLoading(show: false)

                    let armorVC = BaseItemPreviewViewController(delegate: nil, config: ArmorPreviewConfiguration(items: allArmor))
                    armorVC.title = self.armor.material.local()
                    self.delegate?.showViewController(viewController: armorVC)
                }
            }
        case compareCell:
            self.delegate?.showLoading(show: true)

            switch armor.armorType {
            case .body:
                dbManager.getAllBodyArmor() { allArmor in
                    self.delegate?.showLoading(show: false)

                    let compareOptionsVC = ComparisonOptionsViewController(ArmorComparison(self.armor, allArmor: allArmor))
                    self.delegate?.showViewController(viewController: compareOptionsVC)
                }
            case .helmet:
                dbManager.getAllHelmets() { allArmor in
                    self.delegate?.showLoading(show: false)

                    let compareOptionsVC = ComparisonOptionsViewController(ArmorComparison(self.armor, allArmor: allArmor))
                    self.delegate?.showViewController(viewController: compareOptionsVC)
                }
            case .visor, .attachment:
                dbManager.getAllHelmetArmor { allArmor in
                    self.delegate?.showLoading(show: false)

                    let compareOptionsVC = ComparisonOptionsViewController(ArmorComparison(self.armor, allArmor: allArmor))
                    self.delegate?.showViewController(viewController: compareOptionsVC)
                }
            }
        case penChanceCalcCell:
            let penChanceVC = PenChanceCalcViewController()
            penChanceVC.armor = SimulationArmor(json: armor.json)
            delegate?.showViewController(viewController: penChanceVC)
        case combatSimCell:
            self.delegate?.showLoading(show: true)

            DependencyManagerImpl.shared.databaseManager().getCharacters { characters in
                self.delegate?.showLoading(show: false)

                let combatSimVC: CombatSimViewController
                switch self.armor.armorType {
                case .helmet, .visor, .attachment: combatSimVC = CombatSimViewController(characters: characters, initialHeadArmor: SimulationArmor(json: self.armor.json))
                default: combatSimVC = CombatSimViewController(characters: characters, initialBodyArmor: SimulationArmor(json: self.armor.json))
                }

                self.delegate?.showViewController(viewController: combatSimVC)
            }

            case shootingRangeCell:
                self.delegate?.showLoading(show: true)

                DependencyManagerImpl.shared.databaseManager().getCharacters { characters in
                    self.delegate?.showLoading(show: false)

                    guard let defaultChar = characters.first else { return }
                    let shootingRangeVC = ShootingRangeViewController(defaultCharacter: defaultChar)

                    switch self.armor.armorType {
                    case .body: shootingRangeVC.bodyArmor = self.armor
                    default: shootingRangeVC.helmet = self.armor
                    }

                    self.delegate?.showViewController(viewController: shootingRangeVC)
                }
        default:
            fatalError()
        }
    }
}
