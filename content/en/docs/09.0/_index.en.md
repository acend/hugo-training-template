---
title: "9. Persistent Storage"
weight: 9
---

By default, data in pods is not persistent which was e.g. the case in lab 8. This means that data that was written in a pod is lost as soon as that pod does not exist anymore. We want to prevent this from happening. One possible solution to this problem is using persistent storage.


## Request Storage

Attaching persistent storage to a pod happens in two steps. The first step includes the creation of a so-called PersistentVolueClaim (PVC) in our namespace. This claim defines amongst others what name and size we would like to get.

The PersistentVolumeClaim only represents a request but not the storage itself. It is automatically going to be bound to a Persistent Volume by Kubernetes, one that has at least the requested size. If only volumes exist that have a larger size than was requested, one of these volumes is going to be used. The claim will automatically be updated with the new size. If there are only smaller volumes available, the claim will not be bound as long as no volume the exact same or larger size is created.


## Attaching a Volume to a Pod

In a second step, the pvc from before is going to be attached to the right pod. In [lab 6](../06.0/) we edited the deployment configuration in order to insert a readiness probe. We are now going to do the same for inserting the persistent volume.

The following command creates a PersistentVolumeClaim which requests a volume of 1Gi size.  
Save it to `pvc.yaml`:

```yaml
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pv-claim
  labels:
    app: mysql
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```
And deploy with:

```bash
kubectl create -f pvc.yaml --namespace [NAMESPACE]
```

We now have to insert the volume definition in the correct section of the MySQL deployment:

```bash
kubectl edit deployment mysql --namespace [NAMESPACE]
```

Add the the both parts `volumeMounts` and `volumes`
```yaml
...
        resources: {}                                                 
        terminationMessagePath: /dev/termination-log                  
        terminationMessagePolicy: File

        volumeMounts:
        - name: mysql-persistent-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-persistent-storage
        persistentVolumeClaim:
          claimName: mysql-pv-claim

      dnsPolicy: ClusterFirst                                         
      restartPolicy: Always                                           
      schedulerName: default-scheduler
...
```

{{% alert title="Note" color="warning" %}}
Because we just changed the deployment a new pod was automatically redeployed. This unfortunately also means that we just lost the data we inserted before.
{{% /alert %}}

Our application automatically creates the database schema at startup.

{{% alert title="Tip" color="warning" %}}
If you want to force a redeployment of a pod, you could e.g. use this:

```bash
kubectl patch deployment example-web-python -p "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"`date +'%s'`\"}}}}}" --namespace [NAMESPACE]
```
{{% /alert %}}

Using the command `kubectl get persistentvolumeclaim` or - a bit easier to write - `kubectl get pvc --namespace [NAMESPACE]`, we can display the freshly created PersistentVolumeClaim:

```bash
kubectl get pvc --namespace [NAMESPACE]
```

wich give you an output similar to this:

```
NAME             STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
mysql-pv-claim   Bound    pvc-2cb78deb-d157-11e8-a406-42010a840034   1Gi        RWO            standard       11s
```

The two columns `STATUS` and `VOLUME` show us that our claim has been bound to the persistent volume `pvc-2cb78deb-d157-11e8-a406-42010a840034`.

## Error case
If the Container is not able to start it is the right moment to debug it!  
Check the Logs from the Container and search for the error.

```bash
kubectl logs mysql-f845ccdb7-hf2x5 --namespace [NAMESPACE]
```

{{% alert title="Tip" color="warning" %}}
If Container won't start because the data directory has files in it. Mount the volume to a different location in the pod and check the content. Remove it if necessary.
{{% /alert %}}

## Task: Persistence Check

### Restore Data

Repeat the task from [Lab8, Task: Import a Database Dump](../08.0/#task-import-a-database-dump).

### Test

Scale your MySQL pod to 0 replicas and back to 1. Observe that the new pod didn't loose any data.