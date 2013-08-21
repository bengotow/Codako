module.exports = sequelize.define 'World', {

  id: { type: Sequelize.INTEGER, primaryKey: true, autoIncrement: true }
  title: { type: Sequelize.STRING, allowNull: false }
  description: { type: Sequelize.TEXT, allowNull: true }

}, {

  instanceMethods:
    isOwnedBy: (user) -> return @user_id == user.id


}