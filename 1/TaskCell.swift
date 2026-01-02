//
//  TaskCell.swift
//  TodoApp
//
//  Created by Михаил on 27.12.2025.
//

import UIKit

final class TaskCell: UITableViewCell {
    
    // MARK: - UI
    
    private let titleLabel = UILabel()
    private let statusImageView = UIImageView()
    private let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "pencil"), for: .normal)
        button.tintColor = .secondaryLabel
        return button
    }()
    
    var onToggleDone: (() -> Void)?
    var onEdit: (() -> Void)?
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        selectionStyle = .none
        
        statusImageView.frame = CGRect(x: 16, y: 15, width: 24, height: 24)
        statusImageView.contentMode = .scaleAspectFit
        statusImageView.isUserInteractionEnabled = true
        contentView.addSubview(statusImageView)
        
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(didTapStatus))
        statusImageView.addGestureRecognizer(tapGesture)
        
        titleLabel.frame = CGRect(x: 56, y: 15, width: 250, height: 24)
        titleLabel.font = .systemFont(ofSize: 16)
        contentView.addSubview(titleLabel)
        
        editButton.frame = CGRect(
            x: Int(contentView.bounds.width) - 44,
            y: 10,
            width: 24,
            height: 24)
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        contentView.addSubview(editButton)
    }
    
    @objc private func didTapStatus() {
        onToggleDone?()
    }
    @objc private func editTapped() {
        onEdit?()
    }
    
    func configure(with task: Task ) {
        titleLabel.text = task.title
        
        if task.isDone {
            statusImageView.image = UIImage(systemName: "checkmark.circle.fill")
            titleLabel.textColor = .secondaryLabel
        } else {
            statusImageView.image = UIImage(systemName: "circle")
            titleLabel.textColor = .label
        }
    }
    
}
