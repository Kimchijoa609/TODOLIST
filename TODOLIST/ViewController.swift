import UIKit
import CoreData


class ViewController: UIViewController {

    @IBOutlet weak var categoryTableView: UITableView!
    
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    var categoryList = [CategoryList]()
    var todoList = [TodoList]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Todo List"
        
        let nib = UINib(nibName: "CategoryTableViewCell", bundle: nil)
        categoryTableView.register(nib, forCellReuseIdentifier: "CategoryTableViewCell")
        
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        
        fetchData()
        fetchDataTodoList()
        categoryTableView.reloadData()
        
        
    }
    
    func fetchData() {
        let fetchRequest: NSFetchRequest<CategoryList> = CategoryList.fetchRequest()
        let context = appdelegate.persistentContainer.viewContext
        do {
            self.categoryList = try context.fetch(fetchRequest)
        } catch  {
            print(error)
        }
    }
    
    @IBAction func addCategory(_ sender: Any) {
        let alert = UIAlertController(title: "Add Category", message: "원하시는 카테고리를 작성해주세요.", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "확인", style: .default){ (result) in
            if let hasData = alert.textFields?[0].text {
                self.saveCategory(value:hasData)
            }
        }
        
        let cancel = UIAlertAction(title: "취소", style: .default)
        
        alert.addAction(cancel)
        alert.addAction(ok)
        alert.addTextField{ (mytextField) in
            mytextField.placeholder = "카테고리를 입력하세요 .."
        }
        self.present(alert, animated: true)
    }
    
    @IBAction func checkBtn(_ sender: UIBarButtonItem) {
        print(categoryList)
        print(todoList)
    }
    func saveCategory(value : String){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        
        guard let entitiyDescription = NSEntityDescription.entity(forEntityName: "CategoryList", in: context) else { return  }
        
        
        guard let obj = NSManagedObject(entity: entitiyDescription, insertInto: context) as? CategoryList else { return }
        
        obj.name = value
        obj.uuid = UUID()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.saveContext()
        didFinishSaveData()
    }
    
    func deleteCategory(deltitle : String?) {
        
        guard let deltitle = deltitle else { return }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "CategoryList")
        fetchRequest.predicate = NSPredicate(format: "name = %@", deltitle)
        
        do {
            let test = try managedContext.fetch(fetchRequest)
            let objectToDelete = test[0] as! NSManagedObject
            managedContext.delete(objectToDelete)
            do {
                try managedContext.save()
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
        didFinishSaveData()
    }
    
    func didFinishSaveData(){
        self.fetchData()
        self.categoryTableView.reloadData()
    }
    
    
    private func makeTodo(){
        
    }
}

extension  ViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("\(self.categoryList.count + self.todoList.count) 개 ")
        return self.categoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryTableViewCell", for: indexPath) as! CategoryTableViewCell
        
        cell.cellDelegate = self
        cell.title.text = categoryList[indexPath.row].name
        cell.cateUuid = categoryList[indexPath.row].uuid
        if let val = categoryList[indexPath.row].uuid {
            
        }
        cell.title.sizeToFit()

        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: "삭제") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void)   in
            print("성공")
            success(true)
            self.deleteCategory(deltitle:self.categoryList[indexPath.row].name)
        }
        delete.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [delete])
        
    }
}


extension ViewController : CellDelegate {
    // 카테고리의 uuid를 키로 가지는 todolist 만들기 ....
    func categoryButton(cateUUID : UUID?) {
        let alert = UIAlertController(title: "Add Todo", message: "할 일을 작성해주세요.", preferredStyle: .alert)
        
        guard let cateUUID = cateUUID else { return }

        let ok = UIAlertAction(title: "확인", style: .default){ (result) in
            if let hasData = alert.textFields?[0].text {
                print("\(cateUUID), \(hasData)")
                self.saveTodo(value: hasData, cateUUID: cateUUID)
            }
        }
        
        let cancel = UIAlertAction(title: "취소", style: .default)
        
        alert.addAction(cancel)
        alert.addAction(ok)
        alert.addTextField{ (mytextField) in
            mytextField.placeholder = "카테고리를 입력하세요 .."
        }
        self.present(alert, animated: true)
    }
}

// todo 생성 관련 코드 ...
extension ViewController {
    func fetchDataTodoList() {
        let fetchRequest: NSFetchRequest<TodoList> = TodoList.fetchRequest()
        let context = appdelegate.persistentContainer.viewContext
        do {
            self.todoList = try context.fetch(fetchRequest)
        } catch  {
            print(error)
        }
    }
    
    func saveTodo(value : String, cateUUID : UUID){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        
        guard let entitiyDescription = NSEntityDescription.entity(forEntityName: "TodoList", in: context) else { return  }
        
        
        guard let obj = NSManagedObject(entity: entitiyDescription, insertInto: context) as? TodoList else { return }
        
        obj.content = value
        obj.uuid = UUID()
        obj.puuid = cateUUID
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.saveContext()
        didFinishSaveTodoData()
    }
    func didFinishSaveTodoData(){
        self.fetchDataTodoList()
        self.categoryTableView.reloadData()
    }
}
