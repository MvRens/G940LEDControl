unit ObserverIntf;

interface
type
  IObserver = interface
    ['{B78415C9-9F64-4AF1-8983-BACE2B7225EF}']
    procedure Update(Sender: IInterface);
  end;


  IObservable = interface
    ['{BC004BDA-14E4-4923-BE6D-98A0746852F1}']
    procedure Attach(AObserver: IObserver);
    procedure Detach(AObserver: IObserver);
  end;


implementation

end.
