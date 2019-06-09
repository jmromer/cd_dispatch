# frozen_string_literal: true

require "spec_helper"

RSpec.describe CdDispatch::Dispatcher do
  describe "class interface" do
    it { should respond_to(:entries) }
    it { should respond_to(:entries_by_frequency) }
    it { should respond_to(:entries_pruned) }
    it { should respond_to(:new_projects) }
    it { should respond_to(:find_command) }
    it { should respond_to(:entries_updated) }
    it { should respond_to(:parse_path) }
    it { should respond_to(:build_label) }
    it { should respond_to(:project_listing) }
    it { should respond_to(:save) }
    it { should respond_to(:append) }
  end

  describe ".entries"
  describe ".entries_by_frequency"
  describe ".entries_pruned"
  describe ".new_projects"
  describe ".find_command"
  describe ".entries_updated"
  describe ".parse_path"
  describe ".build_label"
  describe ".project_listing"
  describe ".save"
  describe ".append"
end
