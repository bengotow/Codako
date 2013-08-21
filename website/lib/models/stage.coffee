module.exports = sequelize.define 'Stage', {

  id: { type: Sequelize.INTEGER, primaryKey: true, autoIncrement: true }
  content: { type: Sequelize.TEXT, allowNull: true }

}, {

  instanceMethods:
    isOwnedBy: (user) -> return @user_id == user.id

}