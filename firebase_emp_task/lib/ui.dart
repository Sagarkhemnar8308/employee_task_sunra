import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_emp_task/database.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';

class UI extends StatefulWidget {
  const UI({super.key});

  @override
  State<UI> createState() => _UIState();
}

class _UIState extends State<UI> {
  Stream? employeeStream;

  getontheload() async {
    employeeStream = await ContactMethod().getEmployeeDetails();
    setState(() {});
  }

  final TextEditingController _empNameController = TextEditingController();
  final TextEditingController _sallaryController = TextEditingController();
  final TextEditingController _presentday = TextEditingController();

  @override
  void initState() {
    super.initState();
    getontheload();
  }

  Widget allEmployeeDetails() {
    return StreamBuilder(
        stream: employeeStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];
                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey)),
                          height: 140,
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 245,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      // ignore: prefer_interpolation_to_compose_strings
                                      "Name : " + ds["EmpName"],
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 20),
                                    ),
                                    Text(
                                      "Sallary : " + ds["sallary"],
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 20),
                                    ),
                                    Text(
                                      "Present days : " + ds['days'],
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 20),
                                    ),
                                     Text(
                                      "Monthly sallary : " + ds['Givensallary'].toString(),
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  InkWell(
                                      onTap: () {
                                        _empNameController.text = ds['EmpName'];
                                        _sallaryController.text = ds["sallary"];
                                        _presentday.text = ds["days"];
                                        editEmployeeData(ds["Id"]);
                                      },
                                      child: const Icon(Icons.edit)),
                                  InkWell(
                                      onTap: () async {
                                        await ContactMethod()
                                            .deleteEmployeeDetails(ds["Id"]);
                                      },
                                      child: const Icon(Icons.delete)),
                                ],
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    );
                  },
                )
              : const SizedBox();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Scaffold(
      floatingActionButton: IconButton(
          style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.orange)),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FormPage(),
                ));
          },
          icon: const Icon(
            Icons.add,
            color: Colors.black,
          )),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Employee Details",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Expanded(child: allEmployeeDetails()),
          ],
        ),
      ),
    ));
  }

  Future editEmployeeData(String id) => showDialog(
        context: context,
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.green,
              title: const Text("Edit user ..............."),
            ),
            body: Container(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 150,
                    ),
                    TextFormField(
                      controller: _empNameController,
                      decoration: const InputDecoration(
                          hintText: "Employe Name",
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _sallaryController,
                      decoration: const InputDecoration(
                          hintText: "Sallary", border: OutlineInputBorder()),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _presentday,
                      decoration: const InputDecoration(
                          hintText: "Working days",
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 50,
                      width: 150,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () {
                            double? realSalary;
  var monthlySalary = int.parse(_sallaryController.text);
      var workingDays = int.parse(_presentday.text);

      double dailySalary = monthlySalary / 30;
      realSalary = dailySalary * workingDays;

      print(" given sallary from company is $realSalary");

                            Map<String, dynamic> updateInfo = {
                              "EmpName": _empNameController.text,
                              "sallary": _sallaryController.text,
                              "days": _presentday.text,
                              "Givensallary":realSalary,
                              "Id": id
                            };
                            ContactMethod()
                                .updateEmployeeDetails(id, updateInfo)
                                .then((value) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const UI(),
                                  ));
                            });
                          },
                          child: const Text(
                            "Edit data",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          )),
                    )
                  ],
                )),
          );
        },
      );
}

class FormPage extends StatefulWidget {
  const FormPage({super.key});
  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  @override
  Widget build(BuildContext context) {
    final employeeController = TextEditingController();
    final sallaryController = TextEditingController();
    final presentday = TextEditingController();

    double? realSalary;
    void sallaryCount() {
      var monthlySalary = int.parse(sallaryController.text);
      var workingDays = int.parse(presentday.text);

      double dailySalary = monthlySalary / 30;
      realSalary = dailySalary * workingDays;

      print(" given sallary from company is $realSalary");
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
            child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: employeeController,
                decoration: const InputDecoration(
                    hintText: "Employee Name ", border: OutlineInputBorder()),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: sallaryController,
                decoration: const InputDecoration(
                    hintText: "Employee Sallary *",
                    border: OutlineInputBorder()),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: presentday,
                decoration: const InputDecoration(
                    hintText: "Working days", border: OutlineInputBorder()),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 40,
                width: 100,
                child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () async {
                      String id = randomAlphaNumeric(30);
                      sallaryCount();
                      print(" given sallary from company is $realSalary");
                      Map<String, dynamic> employeeInfoMap = {
                        "EmpName": employeeController.text,
                        "sallary": sallaryController.text,
                        "days": presentday.text,
                        "Id": id,
                        "Givensallary": realSalary
                      };
                      await ContactMethod()
                          .addEmployeeDetails(employeeInfoMap, id)
                          .then((value) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            backgroundColor: Colors.orange,
                            content: Text(
                                "Employee Added Successfull y..........................")));

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UI(),
                            ));
                      });
                    },
                    child: const Text(
                      "Add",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    )),
              )
            ],
          ),
        )),
      ),
    );
  }
}
