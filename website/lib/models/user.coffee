module.exports = sequelize.define 'User', {

  id: { type: Sequelize.INTEGER, primaryKey: true, autoIncrement: true}
  email: { type: Sequelize.STRING, allowNull: false}
  nickname: { type: Sequelize.STRING, allowNull: false, unique: true}
  password: { type: Sequelize.STRING, allowNull: false}
  gender: { type: Sequelize.STRING}

}, {

}