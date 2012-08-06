require "#{File.dirname(__FILE__)}/test_helper"


class CallbackTest < Test::Unit::TestCase

  def setup
    @fred   = CallbackParent.create!(:name => "fred")
  end

  def teardown
    CallbackChild.delete_all
    SoftCallbackChild.delete_all
    CallbackParent.delete_all
    Child.delete_all
    SoftChild.delete_all
    Parent.delete_all
  end

  def test_callback_before_soft_destroy_for_soft_children
    @fred.soft_callback_children << pebbles = SoftCallbackChild.new(:name => "pebbles")
    assert_raise PreventSoftDestroyError do
      @fred.destroy
    end
    assert_equal @fred.reload.deleted?, false
    assert_equal pebbles.reload.deleted?, false
  end

  def test_callback_before_destroy_bang_for_soft_children
    @fred.soft_callback_children << pebbles = SoftCallbackChild.new(:name => "pebbles")
    assert_raise PreventDestroyBangError do
      @fred.destroy!
    end
    assert_equal @fred.reload.deleted?, false
    assert_equal pebbles.reload.deleted?, false
  end

  def test_callback_before_soft_destroy
    @fred.callback_children << pebbles = CallbackChild.new(:name => "pebbles")
    assert_raise PreventSoftDestroyError do
      @fred.destroy
    end
    assert_equal @fred.reload.deleted?, false
    assert_not_nil pebbles.reload
  end

  def test_callback_before_destroy!
    @fred.callback_children << pebbles = CallbackChild.new(:name => "pebbles")
    assert_raise PreventDestroyBangError do
      @fred.destroy!
    end
    assert_equal @fred.reload.deleted?, false
    assert_not_nil pebbles.reload
  end

  def test_touch_callback_after_has_many_soft_destroy
    @fred = Parent.create!(:name => "fred")
    @fred.soft_children << pebbles = SoftChild.new(:name => "pebbles")
    previous_updated_at = @fred.updated_at
    pebbles.destroy
    assert_not_equal @fred.reload.updated_at, previous_updated_at
  end

  def test_touch_callback_after_has_many_hard_destroy
    @fred = Parent.create!(:name => "fred")
    @fred.soft_children << pebbles = SoftChild.new(:name => "pebbles")
    previous_updated_at = @fred.updated_at
    pebbles.destroy!
    assert_not_equal @fred.reload.updated_at, previous_updated_at
  end

  def test_touch_callback_after_has_many_destroy
    @fred = Parent.create!(:name => "fred")
    @fred.children << pebbles = Child.new(:name => "pebbles")
    previous_updated_at = @fred.updated_at
    pebbles.destroy
    assert_not_equal @fred.reload.updated_at, previous_updated_at
  end

end