import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:uttopic/models/user.dart';
import 'package:uttopic/models/financial_goal.dart';
import 'package:uttopic/models/activity_data.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late User user;
  late List<FinancialGoal> goals;
  late List<ActivityData> activityData;

  @override
  void initState() {
    super.initState();
    // Simular dados do backend
    user = User(
      name: 'João',
      profilePicUrl: 'assets/profile_pic.png',
      balance: 5280.00,
      income: 3500.00,
      expenses: 2220.00,
      level: 5,
      points: 500,
      achievements: 3,
    );

    goals = [
      FinancialGoal(title: 'Viagem para a Europa', targetAmount: 15000, currentAmount: 10500),
      FinancialGoal(title: 'Novo Notebook', targetAmount: 5000, currentAmount: 2000),
    ];

    activityData = [
      ActivityData(date: DateTime.now().subtract(Duration(days: 30)), value: 3000),
      ActivityData(date: DateTime.now().subtract(Duration(days: 25)), value: 2800),
      ActivityData(date: DateTime.now().subtract(Duration(days: 20)), value: 3200),
      ActivityData(date: DateTime.now().subtract(Duration(days: 15)), value: 3500),
      ActivityData(date: DateTime.now().subtract(Duration(days: 10)), value: 3300),
      ActivityData(date: DateTime.now().subtract(Duration(days: 5)), value: 3700),
      ActivityData(date: DateTime.now(), value: 4000),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Notificações em breve!'))
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(),
                SizedBox(height: 24),
                _buildBalanceCard(),
                SizedBox(height: 24),
                _buildGoalsSection(),
                SizedBox(height: 24),
                _buildActivityGraph(),
                SizedBox(height: 24),
                _buildRewardsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Olá, ${user.name}!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'Bem-vindo de volta',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Editar perfil em breve!'))
            );
          },
          child: CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage(user.profilePicUrl),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saldo Total',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'R\$ ${user.balance.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBalanceItem('Receitas', 'R\$ ${user.income.toStringAsFixed(2)}', Colors.green),
                _buildBalanceItem('Despesas', 'R\$ ${user.expenses.toStringAsFixed(2)}', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceItem(String title, String amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 14, color: Colors.grey)),
        SizedBox(height: 4),
        Text(amount, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildGoalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Metas Ativas',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        ...goals.map((goal) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildGoalCard(goal),
        )).toList(),
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Adicionar nova meta em breve!'))
            );
          },
          child: Text('Adicionar Nova Meta'),
        ),
      ],
    );
  }

  Widget _buildGoalCard(FinancialGoal goal) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(goal.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: goal.progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('R\$ ${goal.currentAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 14, color: Colors.grey)),
                Text('R\$ ${goal.targetAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityGraph() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Atividade Mensal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 6,
                  minY: activityData.map((d) => d.value).reduce((a, b) => a < b ? a : b),
                  maxY: activityData.map((d) => d.value).reduce((a, b) => a > b ? a : b),
                  lineBarsData: [
                    LineChartBarData(
                      spots: activityData.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value.value);
                      }).toList(),
                      isCurved: true,
                      colors: [Colors.blue],
                      barWidth: 5,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recompensas',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildRewardItem(Icons.star, 'Nível ${user.level}'),
            _buildRewardItem(Icons.attach_money, '${user.points} pontos'),
            _buildRewardItem(Icons.emoji_events, '${user.achievements} conquistas'),
          ],
        ),
      ],
    );
  }

  Widget _buildRewardItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, size: 40, color: Colors.amber),
        SizedBox(height: 8),
        Text(text, style: TextStyle(fontSize: 14)),
      ],
    );
  }

  Future<void> _refreshData() async {
    // Simular uma atualização de dados do backend
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      user = User(
        name: user.name,
        profilePicUrl: user.profilePicUrl,
        balance: user.balance + 100,
        income: user.income,
        expenses: user.expenses,
        level: user.level,
        points: user.points + 50,
        achievements: user.achievements,
      );

      goals[0] = FinancialGoal(
        title: goals[0].title,
        targetAmount: goals[0].targetAmount,
        currentAmount: goals[0].currentAmount + 500,
      );

      activityData.add(ActivityData(
        date: DateTime.now(),
        value: activityData.last.value + 300,
      ));
      if (activityData.length > 7) {
        activityData.removeAt(0);
      }
    });
  }
}