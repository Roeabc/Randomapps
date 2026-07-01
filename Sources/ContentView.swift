import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var showingSchemeList = false
    @State private var showingAddRule = false
    
    @State private var name: String = ""
    @State private var firstMinText: String = ""
    @State private var firstMaxText: String = ""
    @State private var secondMinText: String = ""
    @State private var secondMaxText: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("方案名称") {
                    TextField("名称", text: $name)
                        .onChange(of: name) { viewModel.currentScheme.name = $0 }
                }
                
                Section("第一个数范围") {
                    HStack {
                        Text("最小值")
                        TextField("最小值", text: $firstMinText)
                            .keyboardType(.numberPad)
                            .onChange(of: firstMinText) { if let v = Int($0) { viewModel.currentScheme.firstMin = v } }
                    }
                    HStack {
                        Text("最大值")
                        TextField("最大值", text: $firstMaxText)
                            .keyboardType(.numberPad)
                            .onChange(of: firstMaxText) { if let v = Int($0) { viewModel.currentScheme.firstMax = v } }
                    }
                }
                
                Section("第二个数范围") {
                    HStack {
                        Text("最小值")
                        TextField("最小值", text: $secondMinText)
                            .keyboardType(.numberPad)
                            .onChange(of: secondMinText) { if let v = Int($0) { viewModel.currentScheme.secondMin = v } }
                    }
                    HStack {
                        Text("最大值")
                        TextField("最大值", text: $secondMaxText)
                            .keyboardType(.numberPad)
                            .onChange(of: secondMaxText) { if let v = Int($0) { viewModel.currentScheme.secondMax = v } }
                    }
                }
                
                Section("特殊规则（当第一个数等于指定值时）") {
                    ForEach(viewModel.currentScheme.specialRules) { rule in
                        HStack {
                            Text("当 \(rule.triggerNumber)")
                            Spacer()
                            Text("→ \(rule.newSecondMin)-\(rule.newSecondMax)")
                        }
                    }
                    .onDelete { viewModel.currentScheme.specialRules.remove(atOffsets: $0) }
                    
                    Button("添加特殊规则") { showingAddRule = true }
                }
                
                Section {
                    Button {
                        syncToModel()
                        viewModel.generateRandom()
                    } label: {
                        Text("生成随机数").frame(maxWidth: .infinity)
                    }
                    if !viewModel.result.isEmpty {
                        Text("结果: \(viewModel.result)")
                            .font(.title)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                
                Section {
                    Button("保存当前方案到收藏") {
                        syncToModel()
                        viewModel.addCurrentScheme()
                    }
                }
            }
            .navigationTitle("随机数生成器")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("收藏") { syncToModel(); showingSchemeList = true }
                }
            }
            .sheet(isPresented: $showingAddRule) {
                AddSpecialRuleView { viewModel.currentScheme.specialRules.append($0) }
            }
            .sheet(isPresented: $showingSchemeList) {
                SchemeListView().environmentObject(viewModel)
            }
            .onAppear { loadFromModel() }
            .onChange(of: viewModel.currentScheme.id) { _ in loadFromModel() }
        }
    }
    
    func loadFromModel() {
        name = viewModel.currentScheme.name
        firstMinText = "\(viewModel.currentScheme.firstMin)"
        firstMaxText = "\(viewModel.currentScheme.firstMax)"
        secondMinText = "\(viewModel.currentScheme.secondMin)"
        secondMaxText = "\(viewModel.currentScheme.secondMax)"
    }
    
    func syncToModel() {
        viewModel.currentScheme.name = name
        if let v = Int(firstMinText) { viewModel.currentScheme.firstMin = v }
        if let v = Int(firstMaxText) { viewModel.currentScheme.firstMax = v }
        if let v = Int(secondMinText) { viewModel.currentScheme.secondMin = v }
        if let v = Int(secondMaxText) { viewModel.currentScheme.secondMax = v }
    }
}

struct AddSpecialRuleView: View {
    @Environment(\.dismiss) var dismiss
    @State private var triggerNumber = ""
    @State private var newMin = ""
    @State private var newMax = ""
    var onSave: (SpecialRule) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("触发数字") { TextField("数字", text: $triggerNumber).keyboardType(.numberPad) }
                Section("新的第二个数范围") {
                    TextField("最小值", text: $newMin).keyboardType(.numberPad)
                    TextField("最大值", text: $newMax).keyboardType(.numberPad)
                }
            }
            .navigationTitle("新规则")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        guard let t = Int(triggerNumber), let min = Int(newMin), let max = Int(newMax) else { return }
                        onSave(SpecialRule(triggerNumber: t, newSecondMin: min, newSecondMax: max))
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SchemeListView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.savedSchemes) { scheme in
                    Button {
                        viewModel.selectScheme(scheme)
                        dismiss()
                    } label: {
                        VStack(alignment: .leading) {
                            Text(scheme.name).font(.headline)
                            Text("范围1: \(scheme.firstMin)-\(scheme.firstMax)  范围2: \(scheme.secondMin)-\(scheme.secondMax)")
                                .font(.caption).foregroundColor(.secondary)
                            if !scheme.specialRules.isEmpty {
                                Text("\(scheme.specialRules.count)条特殊规则").font(.caption2).foregroundColor(.blue)
                            }
                        }
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach { viewModel.deleteScheme(viewModel.savedSchemes[$0]) }
                }
            }
            .navigationTitle("收藏方案")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("完成") { dismiss() } } }
        }
    }
}