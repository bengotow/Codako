module.exports = sequelize.define 'Comment', {

  id: { type: Sequelize.INTEGER, primaryKey: true, autoIncrement: true }
  type: { type: Sequelize.STRING, allowNull: false }
  content: { type: Sequelize.STRING, allowNull: true }

}, {

  classMethods:
    method1: () -> return 'smth'

  instanceMethods:
    isOwnedBy: (user) -> return @user_id == user.id
}