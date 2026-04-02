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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        titleLabel.textColor = .label
        statusImageView.image = nil
        
        onToggleDone = nil
        onEdit = nil
    }
    
    func animateStatusChange(isDone: Bool) {
        let newImageName = isDone ? "checkmark.circle.fill" : "circle"
        
        UIView.animate(withDuration: 0.15, animations: {
            self.statusImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            self.statusImageView.image = UIImage(systemName: newImageName)
            
            self.titleLabel.textColor = isDone ? .secondaryLabel : .label
            
            UIView.animate(withDuration: 0.15) {
                self.statusImageView.transform = .identity
            }
        }
    }
    
    func setupUI() {
        selectionStyle = .none
        
        statusImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        editButton.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.numberOfLines = 0
        statusImageView.contentMode = .scaleAspectFit
        statusImageView.isUserInteractionEnabled = true
        
        contentView.addSubview(statusImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(editButton)
        
        NSLayoutConstraint.activate([
            statusImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statusImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            statusImageView.widthAnchor.constraint(equalToConstant: 24),
            statusImageView.heightAnchor.constraint(equalToConstant: 24),
            
            editButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            editButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            editButton.widthAnchor.constraint(equalToConstant: 24),
            editButton.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: statusImageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: editButton.leadingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(didTapStatus))
        statusImageView.addGestureRecognizer(tapGesture)
        
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        
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
