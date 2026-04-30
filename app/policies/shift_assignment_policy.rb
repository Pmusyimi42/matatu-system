class ShiftAssignmentPolicy
  attr_reader :user, :shift

  def initialize(user, shift)
    @user = user
    @shift = shift
  end

  def create?
    user.admin? || (user.driver? && user.active?)
  end

  def show?
    user.admin? || shift.driver_id == user.id
  end

  def update?
    user.admin?
  end

  def destroy?
    user.admin?
  end
end
