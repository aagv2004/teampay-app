import '../models/debt.dart';
import '../models/expense.dart';
import '../models/group.dart';
import '../models/member.dart';

final mockMembers = [
  Member(id: 'm1', name: 'Alejandro'),
  Member(id: 'm2', name: 'Beatriz'),
  Member(id: 'm3', name: 'Carlos'),
  Member(id: 'm4', name: 'Diana'),
  Member(id: 'm5', name: 'Eduardo'),
  Member(id: 'm6', name: 'Fernanda'),
  Member(id: 'm7', name: 'Gustavo'),
  Member(id: 'm8', name: 'Hilda'),
  Member(id: 'm9', name: 'Isabel'),
  Member(id: 'm10', name: 'Jorge'),
  Member(id: 'm11', name: 'Pedro'),
  Member(id: 'm12', name: 'Juan'),
  Member(id: 'm13', name: 'Diego'),
];

final mockExpenses = [
  Expense(
    id: 'e1',
    groupId: 'g1',
    title: 'Comida',
    amount: 25000,
    paidByMemberId: 'm1',
    splitBetweenMemberIds: ['m1', 'm2', 'm3', 'm4', 'm5'],
    createdAt: DateTime(2026, 5, 20),
  ),
  Expense(
    id: 'e2',
    groupId: 'g1',
    title: 'Transporte',
    amount: 12500,
    paidByMemberId: 'm2',
    splitBetweenMemberIds: ['m1', 'm2', 'm3', 'm4', 'm5'],
    createdAt: DateTime(2026, 5, 21),
  ),
];

final mockDebts = [
  Debt(
    id: 'd1',
    expenseId: 'e1',
    groupId: 'g1',
    fromMemberId: 'm2',
    toMemberId: 'm1',
    amount: 6250,
    paidAmount: 0,
  ),
  Debt(
    id: 'd2',
    expenseId: 'e1',
    groupId: 'g1',
    fromMemberId: 'm3',
    toMemberId: 'm1',
    amount: 6250,
    paidAmount: 6250,
    paymentMethod: PaymentMethod.transfer,
  ),
  Debt(
    id: 'd3',
    expenseId: 'e1',
    groupId: 'g1',
    fromMemberId: 'm4',
    toMemberId: 'm1',
    amount: 6250,
    paidAmount: 3000,
    paymentMethod: PaymentMethod.cash,
  ),
  Debt(
    id: 'd4',
    expenseId: 'e1',
    groupId: 'g1',
    fromMemberId: 'm5',
    toMemberId: 'm1',
    amount: 4000,
    paidAmount: 0,
  ),
  Debt(
    id: 'd5',
    expenseId: 'e2',
    groupId: 'g1',
    fromMemberId: 'm1',
    toMemberId: 'm2',
    amount: 4000,
    paidAmount: 1500,
    paymentMethod: PaymentMethod.transfer,
  ),
];

final mockGroups = [
  Group(
    id: 'g1',
    name: 'Viaje escolar',
    ownerMemberId: 'm1',
    members: mockMembers,
    expenses: mockExpenses,
    debts: mockDebts,
    createdAt: DateTime(2026, 5, 20),
  ),
  Group(
    id: 'g2',
    name: 'Departamento',
    ownerMemberId: 'm11',
    members: [
      Member(id: 'm11', name: 'Pedro'),
      Member(id: 'm12', name: 'Juan'),
      Member(id: 'm13', name: 'Diego'),
    ],
    expenses: [],
    debts: [],
    createdAt: DateTime(2026, 5, 18),
  ),
];
