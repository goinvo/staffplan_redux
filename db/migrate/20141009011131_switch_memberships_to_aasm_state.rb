class SwitchMembershipsToAasmState < ActiveRecord::Migration
  def up
    add_column :memberships, :aasm_state, :string, null: false, default: "active"

    Membership.all.each do |membership|
      if membership.archived == true
        membership.archive
      elsif membership.disabled == true
        membership.disable
      end
      membership.save
    end

    remove_column :memberships, :disabled
    remove_column :memberships, :archived
  end

  def down
    add_column :memberships, :disabled, :boolean, null: false, default: false
    add_column :memberships, :archived, :boolean, null: false, default: false

    Membership.all.each do |membership|
      if membership.archived?
        membership.archived = true
      elsif membership.disabled?
        membership.disabled = true
      end
      membership.save
    end

    remove_column :memberships, :aasm_state
  end
end
